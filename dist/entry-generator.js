var Base, ClassInfo, ESCodeGenerator, EntryGenerator, EntryGeneratorInput, Facade, JSCodeGenerator, MasterDataResource, Path, camelize, fs, ref, requireFile,
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

ref = require('./util'), requireFile = ref.requireFile, camelize = ref.camelize;

Facade = require('./main');

Base = Facade.Base;

MasterDataResource = require('./master-data-resource');

ClassInfo = (function() {
  function ClassInfo(name1, relPath1, className1, prefix1) {
    this.name = name1;
    this.relPath = relPath1;
    this.className = className1;
    this.prefix = prefix1;
  }

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
    this.masterJSONStr = JSON.stringify(this.getMasterJSON());
    this.facadeClassName = requireFile(this.absolutePath(facadePath)).name;
  }


  /**
  @return {Array(ClassInfo)}
   */

  EntryGeneratorInput.prototype.getClassInfoList = function(dirPath, prefix) {
    var className, filename, i, len, name, ref1, relDirname, relPath, results;
    if (prefix == null) {
      prefix = '';
    }
    relDirname = this.relativePath(dirPath);
    ref1 = this.getClassFiles(dirPath);
    results = [];
    for (i = 0, len = ref1.length; i < len; i++) {
      filename = ref1[i];
      name = filename.split('.')[0];
      relPath = relDirname + '/' + name;
      className = requireFile(Path.resolve(dirPath, name)).name;
      results.push(new ClassInfo(name, relPath, className, prefix));
    }
    return results;
  };


  /**
  @return {{[string]: Array(ClassInfo)}}
   */

  EntryGeneratorInput.prototype.getModulesClasses = function() {
    var i, len, moduleName, moduleNameCamelized, modulePath, modules, ref1;
    modules = {};
    ref1 = this.getModuleNames();
    for (i = 0, len = ref1.length; i < len; i++) {
      moduleName = ref1[i];
      modulePath = Path.join(this.absDirname, moduleName);
      moduleNameCamelized = camelize(moduleName);
      modules[moduleName] = this.getClassInfoList(modulePath, moduleNameCamelized);
    }
    return modules;
  };


  /**
  @method getMasterJSON
  @private
  @return {Object} master data
   */

  EntryGeneratorInput.prototype.getMasterJSON = function() {
    var allModules, e, error, facade, i, len, masterJSONPath, moduleName, ref1;
    allModules = {};
    ref1 = this.getModuleNames();
    for (i = 0, len = ref1.length; i < len; i++) {
      moduleName = ref1[i];
      allModules[moduleName] = Path.join(this.absDirname, moduleName);
    }
    try {
      facade = Facade.createInstance({
        dirname: this.absDirname,
        modules: allModules,
        master: true
      });
      masterJSONPath = facade.master.masterJSONPath;
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
    var ParentClass, ext, fileInfo, fileInfoDict, filename, files, i, klass, len, name, pntFileName, ref1, ref2, ref3;
    fileInfoDict = {};
    ref1 = fs.readdirSync(path);
    for (i = 0, len = ref1.length; i < len; i++) {
      filename = ref1[i];
      ref2 = filename.split('.'), name = ref2[0], ext = ref2[1];
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
      if (ParentClass.className && (pntFileName = (ref3 = fileInfoDict[ParentClass.getName()]) != null ? ref3.filename : void 0)) {
        if (indexOf.call(files, pntFileName) < 0) {
          files.push(pntFileName);
        }
      }
      files.push(filename);
    }
    return files;
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
    var coreClasses, facadeClassName, masterJSONStr, modules, ref1;
    ref1 = this.input, coreClasses = ref1.coreClasses, modules = ref1.modules, masterJSONStr = ref1.masterJSONStr, facadeClassName = ref1.facadeClassName;
    return "const packedData = {\n    // eslint-disable-next-line quotes, key-spacing, object-curly-spacing, comma-spacing\n    masterData : " + masterJSONStr + ",\n    core: {\n" + (this.getPackedCode(coreClasses, 2)) + ",\n    },\n    modules: {\n" + (this.getModulesPackedData(modules)) + "\n    }\n}\n" + facadeClassName + ".prototype.init = function init() { return this.initWithPacked(packedData) }";
  };

  EntryGenerator.prototype.getPackedCode = function(classes, indent) {
    var i, ref1, results, spaces;
    spaces = (function() {
      results = [];
      for (var i = 0, ref1 = indent * 4; 0 <= ref1 ? i < ref1 : i > ref1; 0 <= ref1 ? i++ : i--){ results.push(i); }
      return results;
    }).apply(this).map(function(x) {
      return ' ';
    }).join('');
    return spaces + classes.map(function(classInfo) {
      return "'" + classInfo.name + "': " + classInfo.prefix + classInfo.className;
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

  return EntryGenerator;

})();

JSCodeGenerator = (function(superClass) {
  extend(JSCodeGenerator, superClass);

  function JSCodeGenerator() {
    return JSCodeGenerator.__super__.constructor.apply(this, arguments);
  }

  JSCodeGenerator.prototype.getPragmas = function() {
    return "/* eslint quote-props: 0, object-shorthand: 0, no-underscore-dangle: 0 */\nconst __ = function __(m) { return m.default ? m.default : m }";
  };

  JSCodeGenerator.prototype.getImportStatements = function() {
    var classInfo, code, coreClasses, facadeClassName, facadePath, i, j, len, len1, modClasses, modName, modules, ref1;
    ref1 = this.input, coreClasses = ref1.coreClasses, modules = ref1.modules, facadePath = ref1.facadePath, facadeClassName = ref1.facadeClassName;
    code = this.getRequireStatement(facadeClassName, facadePath);
    for (i = 0, len = coreClasses.length; i < len; i++) {
      classInfo = coreClasses[i];
      code += this.getRequireStatement(classInfo.className, classInfo.relPath);
    }
    for (modName in modules) {
      modClasses = modules[modName];
      for (j = 0, len1 = modClasses.length; j < len1; j++) {
        classInfo = modClasses[j];
        code += this.getRequireStatement(classInfo.prefix + classInfo.className, classInfo.relPath);
      }
    }
    return code;
  };

  JSCodeGenerator.prototype.getExportStatements = function() {
    var classNames, coreClasses, facadeClassName, keyValues, modClasses, modName, modules, ref1;
    ref1 = this.input, coreClasses = ref1.coreClasses, modules = ref1.modules, facadeClassName = ref1.facadeClassName;
    classNames = coreClasses.map(function(coreClass) {
      return coreClass.className;
    });
    for (modName in modules) {
      modClasses = modules[modName];
      classNames = classNames.concat(modClasses.map(function(modClass) {
        return modClass.prefix + modClass.className;
      }));
    }
    keyValues = classNames.map(function(className) {
      return className + ": " + className;
    });
    return "module.exports = {\n    " + facadeClassName + ": " + facadeClassName + ",\n    " + (keyValues.join(',\n    ')) + "\n}";
  };

  JSCodeGenerator.prototype.getRequireStatement = function(className, path) {
    return "const " + className + " = __(require('" + path + "'))\n";
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
    var classInfo, code, coreClasses, facadeClassName, facadePath, i, j, len, len1, modClasses, modName, modules, ref1;
    ref1 = this.input, coreClasses = ref1.coreClasses, modules = ref1.modules, facadePath = ref1.facadePath, facadeClassName = ref1.facadeClassName;
    code = this.getImportStatement(facadeClassName, facadePath);
    for (i = 0, len = coreClasses.length; i < len; i++) {
      classInfo = coreClasses[i];
      code += this.getImportStatement(classInfo.className, classInfo.relPath);
    }
    for (modName in modules) {
      modClasses = modules[modName];
      for (j = 0, len1 = modClasses.length; j < len1; j++) {
        classInfo = modClasses[j];
        code += this.getImportStatement(classInfo.prefix + classInfo.className, classInfo.relPath);
      }
    }
    return code;
  };

  ESCodeGenerator.prototype.getExportStatements = function() {
    var classNames, coreClasses, facadeClassName, modClasses, modName, modules, ref1;
    ref1 = this.input, coreClasses = ref1.coreClasses, modules = ref1.modules, facadeClassName = ref1.facadeClassName;
    classNames = coreClasses.map(function(coreClass) {
      return coreClass.className;
    });
    for (modName in modules) {
      modClasses = modules[modName];
      classNames = classNames.concat(modClasses.map(function(modClass) {
        return modClass.prefix + modClass.className;
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
