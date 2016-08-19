var Base, BaseModel, ClassInfo, ESCodeGenerator, EntryGenerator, EntryGeneratorInput, Facade, JSCodeGenerator, MasterDataResource, Path, camelize, fs, requireFile,
  indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; },
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

fs = require('fs');

Path = require('path');

if (Path.isAbsolute == null) {
  Path.isAbsolute = function(str) {
    return str.charAt(0) === '/';
  };
}

camelize = require('./util').camelize;

Facade = require('./main');

requireFile = Facade.requireFile;

Base = Facade.Base, BaseModel = Facade.BaseModel;

MasterDataResource = require('./master-data-resource');

ClassInfo = (function() {
  function ClassInfo(name1, relPath1, className1, moduleName1) {
    this.name = name1;
    this.relPath = relPath1;
    this.className = className1;
    this.moduleName = moduleName1;
  }

  Object.defineProperties(ClassInfo.prototype, {
    modFullName: {
      get: function() {
        if (this.moduleName) {
          return this.moduleName + '/' + this.name;
        } else {
          return this.name;
        }
      }
    },
    fullClassName: {
      get: function() {
        return camelize(this.moduleName) + this.className;
      }
    }
  });

  return ClassInfo;

})();

EntryGeneratorInput = (function() {
  function EntryGeneratorInput(facadePath, dirname, outfile) {
    this.validate(facadePath, dirname, outfile);
    this.absDirname = this.absolutePath(dirname);
    this.absOutfilePath = this.absolutePath(outfile);
    this.facadePath = this.relativePath(facadePath);
    this.coreClasses = this.getClassInfoList(this.absDirname);
    this.modules = this.getModulesClasses();
    this.facadeClassName = requireFile(this.absolutePath(facadePath)).name;
    this.facade = this.createFacade();
    this.masterJSONStr = JSON.stringify(this.getMasterJSON());
    this.factories = this.getPreferredFactoryNames();
  }

  EntryGeneratorInput.prototype.createFacade = function() {
    var allModules, i, len, moduleName, ref;
    allModules = {};
    ref = this.getModuleNames();
    for (i = 0, len = ref.length; i < len; i++) {
      moduleName = ref[i];
      allModules[moduleName] = Path.join(this.absDirname, moduleName);
    }
    return Facade.createInstance({
      dirname: this.absDirname,
      modules: allModules,
      master: true
    });
  };


  /**
  @return {Array(ClassInfo)}
   */

  EntryGeneratorInput.prototype.getClassInfoList = function(dirPath, moduleName) {
    var className, filename, i, len, name, ref, relDirname, relPath, results;
    if (moduleName == null) {
      moduleName = '';
    }
    relDirname = this.relativePath(dirPath);
    ref = this.getClassFiles(dirPath);
    results = [];
    for (i = 0, len = ref.length; i < len; i++) {
      filename = ref[i];
      name = filename.split('.')[0];
      relPath = relDirname + '/' + name;
      className = requireFile(Path.resolve(dirPath, name)).name;
      results.push(new ClassInfo(name, relPath, className, moduleName));
    }
    return results;
  };


  /**
  @return {{[string]: Array(ClassInfo)}}
   */

  EntryGeneratorInput.prototype.getModulesClasses = function() {
    var i, len, moduleName, modulePath, modules, ref;
    modules = {};
    ref = this.getModuleNames();
    for (i = 0, len = ref.length; i < len; i++) {
      moduleName = ref[i];
      modulePath = Path.join(this.absDirname, moduleName);
      modules[moduleName] = this.getClassInfoList(modulePath, moduleName);
    }
    return modules;
  };


  /**
  @method getMasterJSON
  @private
  @return {Object} master data
   */

  EntryGeneratorInput.prototype.getMasterJSON = function() {
    var e, error, masterJSONPath;
    try {
      masterJSONPath = this.facade.master.masterJSONPath;
      if (!fs.existsSync(masterJSONPath)) {
        return null;
      }
      return require(masterJSONPath);
    } catch (error) {
      e = error;
      return null;
    }
  };


  /**
  @return {Array(string)} array of module names
   */

  EntryGeneratorInput.prototype.getModuleNames = function() {
    return fs.readdirSync(this.absDirname).filter(function(subDirName) {
      return subDirName !== 'master-data';
    }).filter(function(subDirName) {
      return subDirName !== 'custom-roles';
    }).map((function(_this) {
      return function(subDirname) {
        return Path.join(_this.absDirname, subDirname);
      };
    })(this)).filter(function(subDirPath) {
      return fs.statSync(subDirPath).isDirectory();
    }).filter(function(subDirPath) {
      return fs.readdirSync(subDirPath).some(function(filename) {
        var klass;
        klass = requireFile(Path.join(subDirPath, filename));
        return klass.isBaseDomainClass;
      });
    }).map(function(subDirPath) {
      return Path.basename(subDirPath);
    });
  };


  /**
  get domain files to load
  
  @method getClassFiles
  @private
  @return {Array(string)} filenames
   */

  EntryGeneratorInput.prototype.getClassFiles = function(path) {
    var ParentClass, ext, fileInfo, fileInfoDict, filename, files, i, klass, len, name, pntFileName, ref, ref1, ref2;
    fileInfoDict = {};
    ref = fs.readdirSync(path);
    for (i = 0, len = ref.length; i < len; i++) {
      filename = ref[i];
      ref1 = filename.split('.'), name = ref1[0], ext = ref1[1];
      if (ext !== 'js' && ext !== 'coffee') {
        continue;
      }
      klass = requireFile(path + '/' + filename);
      fileInfoDict[name] = {
        filename: filename,
        klass: klass
      };
    }
    files = [];
    for (name in fileInfoDict) {
      fileInfo = fileInfoDict[name];
      klass = fileInfo.klass, filename = fileInfo.filename;
      if (indexOf.call(files, filename) >= 0) {
        continue;
      }
      ParentClass = Object.getPrototypeOf(klass.prototype).constructor;
      if (ParentClass.className && (pntFileName = (ref2 = fileInfoDict[ParentClass.getName()]) != null ? ref2.filename : void 0)) {
        if (indexOf.call(files, pntFileName) < 0) {
          files.push(pntFileName);
        }
      }
      files.push(filename);
    }
    return files;
  };


  /**
  get entities with no factory
   */

  EntryGeneratorInput.prototype.getPreferredFactoryNames = function() {
    var classInfo, classes, factories, i, j, k, len, len1, modName, ref, ref1, v;
    factories = {};
    ref = this.coreClasses;
    for (i = 0, len = ref.length; i < len; i++) {
      classInfo = ref[i];
      factories[classInfo.modFullName] = this.getPreferredFactoryName(classInfo);
    }
    ref1 = this.modules;
    for (modName in ref1) {
      classes = ref1[modName];
      for (j = 0, len1 = classes.length; j < len1; j++) {
        classInfo = classes[j];
        factories[classInfo.modFullName] = this.getPreferredFactoryName(classInfo);
      }
    }
    for (k in factories) {
      v = factories[k];
      if (v == null) {
        delete factories[k];
      }
    }
    return factories;
  };

  EntryGeneratorInput.prototype.getPreferredFactoryName = function(classInfo) {
    var ModelClass, e, error, factory;
    ModelClass = this.facade.require(classInfo.modFullName);
    if (!(ModelClass.prototype instanceof BaseModel)) {
      return;
    }
    try {
      factory = this.facade.createPreferredFactory(classInfo.modFullName);
      return "'" + factory.constructor.className + "'";
    } catch (error) {
      e = error;
      return 'null';
    }
  };


  /**
  validate input data
   */

  EntryGeneratorInput.prototype.validate = function(facadePath, dirname, outfile) {
    var absDirname, absFacadePath, outDir;
    absFacadePath = this.absolutePath(facadePath);
    absDirname = this.absolutePath(dirname);
    outDir = Path.dirname(this.absolutePath(outfile));
    if (!fs.existsSync(absFacadePath)) {
      throw new Error("'" + absFacadePath + "' is not found.");
    }
    if (!fs.existsSync(absDirname)) {
      throw new Error("dirname: '" + absDirname + "' is not found.");
    }
    if (!fs.existsSync(outDir)) {
      throw new Error("output directory: '" + outDir + "' is not found.");
    }
  };

  EntryGeneratorInput.prototype.absolutePath = function(path) {
    if (Path.isAbsolute(path)) {
      return Path.resolve(path);
    }
    return Path.resolve(process.cwd(), path);
  };

  EntryGeneratorInput.prototype.relativePath = function(path) {
    var relPath;
    relPath = Path.relative(Path.dirname(this.absOutfilePath), path);
    if (relPath.charAt(0) !== '.') {
      relPath = './' + relPath;
    }
    return relPath;
  };

  return EntryGeneratorInput;

})();

EntryGenerator = (function() {
  EntryGenerator.generate = function(facadePath, dirname, outfile, esCode) {
    var generator, input;
    if (esCode == null) {
      esCode = false;
    }
    input = new EntryGeneratorInput(facadePath, dirname, outfile);
    if (esCode) {
      generator = new ESCodeGenerator(input);
    } else {
      generator = new JSCodeGenerator(input);
    }
    return generator.generate();
  };

  function EntryGenerator(input1) {
    this.input = input1;
  }

  EntryGenerator.prototype.generate = function() {
    var code;
    code = [this.getPragmas(), this.getImportStatements(), this.getPackedData(), this.getExportStatements()].join('\n') + '\n';
    return fs.writeFileSync(this.input.absOutfilePath, code);
  };

  EntryGenerator.prototype.getPragmas = function() {
    return '';
  };

  EntryGenerator.prototype.getPackedData = function() {
    var coreClasses, facadeClassName, factories, masterJSONStr, modules, ref;
    ref = this.input, factories = ref.factories, coreClasses = ref.coreClasses, modules = ref.modules, masterJSONStr = ref.masterJSONStr, facadeClassName = ref.facadeClassName;
    return "var packedData = {\n    // eslint-disable-next-line quotes, key-spacing, object-curly-spacing, comma-spacing\n    masterData : " + masterJSONStr + ",\n    core: {\n" + (this.getPackedCode(coreClasses, 2)) + ",\n    },\n    modules: {\n" + (this.getModulesPackedData(modules)) + "\n    },\n    factories: {\n" + (this.getFactoriesPackedData(factories, 2)) + "\n    }\n}\n" + facadeClassName + ".prototype.init = function init() { return this.initWithPacked(packedData) }";
  };

  EntryGenerator.prototype.getPackedCode = function(classes, indent) {
    var i, ref, results, spaces;
    spaces = (function() {
      results = [];
      for (var i = 0, ref = indent * 4; 0 <= ref ? i < ref : i > ref; 0 <= ref ? i++ : i--){ results.push(i); }
      return results;
    }).apply(this).map(function(x) {
      return ' ';
    }).join('');
    return spaces + classes.map(function(classInfo) {
      return "'" + classInfo.name + "': " + classInfo.fullClassName;
    }).join(',\n' + spaces);
  };

  EntryGenerator.prototype.getModulesPackedData = function(modules) {
    var _;
    _ = '        ';
    return Object.keys(modules).map((function(_this) {
      return function(modName) {
        var modClasses;
        modClasses = modules[modName];
        return _ + "'" + modName + "': {\n" + (_this.getPackedCode(modClasses, 3)) + "\n" + _ + "}";
      };
    })(this)).join(',\n');
  };

  EntryGenerator.prototype.getFactoriesPackedData = function(factories, indent) {
    var i, ref, results, spaces;
    spaces = (function() {
      results = [];
      for (var i = 0, ref = indent * 4; 0 <= ref ? i < ref : i > ref; 0 <= ref ? i++ : i--){ results.push(i); }
      return results;
    }).apply(this).map(function(x) {
      return ' ';
    }).join('');
    return spaces + Object.keys(factories).map((function(_this) {
      return function(modelName) {
        var factoryName;
        factoryName = factories[modelName];
        return "'" + modelName + "': " + factoryName;
      };
    })(this)).join(',\n' + spaces);
  };

  return EntryGenerator;

})();

JSCodeGenerator = (function(superClass) {
  extend(JSCodeGenerator, superClass);

  function JSCodeGenerator() {
    return JSCodeGenerator.__super__.constructor.apply(this, arguments);
  }

  JSCodeGenerator.prototype.getPragmas = function() {
    return "/* eslint quote-props: 0, object-shorthand: 0, no-underscore-dangle: 0 */\nvar __ = function __(m) { return m.default ? m.default : m }";
  };

  JSCodeGenerator.prototype.getImportStatements = function() {
    var classInfo, code, coreClasses, facadeClassName, facadePath, i, j, len, len1, modClasses, modName, modules, ref;
    ref = this.input, coreClasses = ref.coreClasses, modules = ref.modules, facadePath = ref.facadePath, facadeClassName = ref.facadeClassName;
    code = this.getRequireStatement(facadeClassName, facadePath);
    for (i = 0, len = coreClasses.length; i < len; i++) {
      classInfo = coreClasses[i];
      code += this.getRequireStatement(classInfo.className, classInfo.relPath);
    }
    for (modName in modules) {
      modClasses = modules[modName];
      for (j = 0, len1 = modClasses.length; j < len1; j++) {
        classInfo = modClasses[j];
        code += this.getRequireStatement(classInfo.fullClassName, classInfo.relPath);
      }
    }
    return code;
  };

  JSCodeGenerator.prototype.getExportStatements = function() {
    var classNames, coreClasses, facadeClassName, keyValues, modClasses, modName, modules, ref;
    ref = this.input, coreClasses = ref.coreClasses, modules = ref.modules, facadeClassName = ref.facadeClassName;
    classNames = coreClasses.map(function(coreClass) {
      return coreClass.className;
    });
    for (modName in modules) {
      modClasses = modules[modName];
      classNames = classNames.concat(modClasses.map(function(modClass) {
        return modClass.fullClassName;
      }));
    }
    keyValues = classNames.map(function(className) {
      return className + ": " + className;
    });
    return "module.exports = {\n    \"default\": " + facadeClassName + ",\n    " + facadeClassName + ": " + facadeClassName + ",\n    " + (keyValues.join(',\n    ')) + "\n}";
  };

  JSCodeGenerator.prototype.getRequireStatement = function(className, path) {
    return "var " + className + " = __(require('" + path + "'))\n";
  };

  return JSCodeGenerator;

})(EntryGenerator);

ESCodeGenerator = (function(superClass) {
  extend(ESCodeGenerator, superClass);

  function ESCodeGenerator() {
    return ESCodeGenerator.__super__.constructor.apply(this, arguments);
  }

  ESCodeGenerator.prototype.getPragmas = function() {
    return "// @flow\n/* eslint quote-props: 0, max-len: 0 */";
  };

  ESCodeGenerator.prototype.getImportStatements = function() {
    var classInfo, code, coreClasses, facadeClassName, facadePath, i, j, len, len1, modClasses, modName, modules, ref;
    ref = this.input, coreClasses = ref.coreClasses, modules = ref.modules, facadePath = ref.facadePath, facadeClassName = ref.facadeClassName;
    code = this.getImportStatement(facadeClassName, facadePath);
    for (i = 0, len = coreClasses.length; i < len; i++) {
      classInfo = coreClasses[i];
      code += this.getImportStatement(classInfo.className, classInfo.relPath);
    }
    for (modName in modules) {
      modClasses = modules[modName];
      for (j = 0, len1 = modClasses.length; j < len1; j++) {
        classInfo = modClasses[j];
        code += this.getImportStatement(classInfo.fullClassName, classInfo.relPath);
      }
    }
    return code;
  };

  ESCodeGenerator.prototype.getExportStatements = function() {
    var classNames, coreClasses, facadeClassName, modClasses, modName, modules, ref;
    ref = this.input, coreClasses = ref.coreClasses, modules = ref.modules, facadeClassName = ref.facadeClassName;
    classNames = coreClasses.map(function(coreClass) {
      return coreClass.className;
    });
    for (modName in modules) {
      modClasses = modules[modName];
      classNames = classNames.concat(modClasses.map(function(modClass) {
        return modClass.fullClassName;
      }));
    }
    return "export default " + facadeClassName + "\nexport {\n    " + facadeClassName + ",\n    " + (classNames.join(',\n    ')) + "\n}";
  };


  /**
  get import statement from className and path
   */

  ESCodeGenerator.prototype.getImportStatement = function(className, path) {
    return "import " + className + " from '" + path + "'\n";
  };

  return ESCodeGenerator;

})(EntryGenerator);

module.exports = EntryGenerator;
