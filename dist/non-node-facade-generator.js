'use strict';
var Base, Facade, MasterDataResource, NonNodeFacadeGenerator, Path, fs, requireFile,
  indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

fs = require('fs');

Path = require('path');

if (Path.isAbsolute == null) {
  Path.isAbsolute = function(str) {
    return str.charAt(0) === '/';
  };
}

requireFile = require('./util').requireFile;

Facade = require('./main');

Base = Facade.Base;

MasterDataResource = require('./master-data-resource');

NonNodeFacadeGenerator = (function() {
  function NonNodeFacadeGenerator() {}

  NonNodeFacadeGenerator.prototype.generate = function(facadePath, dirname, outfile) {
    var absDirname, absFacadePath, code, cwd, outfilePath;
    absFacadePath = this.absolutePath(facadePath);
    absDirname = this.absolutePath(dirname);
    outfilePath = this.absolutePath(outfile);
    this.validate(facadePath, absDirname, outfilePath);
    cwd = Path.dirname(outfilePath);
    code = "function __(m) { return m.default? m.default : m }\n";
    code += this.getPackedDataCode(absDirname, cwd) + '\n';
    code += "const Facade = __(require('" + (this.relativePath(absFacadePath, cwd)) + "'))\nFacade.prototype.init = function() { return this.initWithPacked(packedData) }\nmodule.exports = Facade";
    return fs.writeFileSync(outfilePath, code);
  };

  NonNodeFacadeGenerator.prototype.validate = function(absFacadePath, absDirname, outfilePath) {
    var outDir;
    if (!fs.existsSync(absFacadePath)) {
      throw new Error("'" + absFacadePath + "' is not found.");
    }
    if (!fs.existsSync(absDirname)) {
      throw new Error("dirname: '" + absDirname + "' is not found.");
    }
    outDir = Path.dirname(outfilePath);
    if (!fs.existsSync(outDir)) {
      throw new Error("output directory: '" + outDir + "' is not found.");
    }
  };

  NonNodeFacadeGenerator.prototype.getPackedDataCode = function(dirname, cwd) {
    var propCodes;
    propCodes = [];
    propCodes.push(this.getMasterProp(dirname, cwd));
    propCodes.push(this.getCoreProp(dirname, cwd));
    propCodes.push(this.getModulesProp(dirname, cwd));
    return "const packedData = {\n" + (propCodes.join(',\n')) + "\n}";
  };

  NonNodeFacadeGenerator.prototype.getMasterProp = function(dirname, cwd) {
    var masterJSONPath;
    if (masterJSONPath = this.getMasterJSONPath(dirname, cwd)) {
      return "  masterData: require('" + masterJSONPath + "')";
    } else {
      return "  masterData: null";
    }
  };

  NonNodeFacadeGenerator.prototype.getCoreProp = function(dirname, cwd) {
    var coreCodes, filename, name, path;
    coreCodes = (function() {
      var i, len, ref, results;
      ref = this.getClassFiles(dirname);
      results = [];
      for (i = 0, len = ref.length; i < len; i++) {
        filename = ref[i];
        name = filename.split('.')[0];
        path = this.relativePath(dirname, cwd) + '/' + name;
        results.push("    '" + name + "': __(require('" + path + "'))");
      }
      return results;
    }).call(this);
    return "  core: {\n" + (coreCodes.join(',\n')) + "\n  }";
  };

  NonNodeFacadeGenerator.prototype.getModulesProp = function(dirname, cwd) {
    var filename, moduleCodes, moduleName, modulePath, modulesCode, name, path;
    modulesCode = (function() {
      var i, len, ref, results;
      ref = this.getModuleNames(dirname);
      results = [];
      for (i = 0, len = ref.length; i < len; i++) {
        moduleName = ref[i];
        modulePath = Path.join(dirname, moduleName);
        moduleCodes = (function() {
          var j, len1, ref1, results1;
          ref1 = this.getClassFiles(modulePath);
          results1 = [];
          for (j = 0, len1 = ref1.length; j < len1; j++) {
            filename = ref1[j];
            name = filename.split('.')[0];
            path = this.relativePath(modulePath, cwd) + '/' + name;
            results1.push("      '" + name + "': __(require('" + path + "'))");
          }
          return results1;
        }).call(this);
        results.push("    " + moduleName + ": {\n" + (moduleCodes.join(',\n')) + "\n    }");
      }
      return results;
    }).call(this);
    return "  modules: {\n" + (modulesCode.join(',\n')) + "\n  }";
  };

  NonNodeFacadeGenerator.prototype.getModuleNames = function(dirname) {
    var path;
    path = this.absolutePath(dirname);
    return fs.readdirSync(path).filter(function(subDirName) {
      return subDirName !== 'master-data';
    }).filter(function(subDirName) {
      return subDirName !== 'custom-roles';
    }).map(function(subDirname) {
      return Path.join(dirname, subDirname);
    }).filter(function(subDirPath) {
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
  @method getCodeOfMasterData
  @private
  @return {String} path
   */

  NonNodeFacadeGenerator.prototype.getMasterJSONPath = function(dirname, cwd) {
    var allModules, e, error, facade, i, len, masterJSONPath, moduleName, ref, relPath;
    allModules = {};
    ref = this.getModuleNames(dirname);
    for (i = 0, len = ref.length; i < len; i++) {
      moduleName = ref[i];
      allModules[moduleName] = Path.join(dirname, moduleName);
    }
    try {
      facade = Facade.createInstance({
        dirname: this.absolutePath(dirname),
        modules: allModules,
        master: true
      });
      masterJSONPath = facade.master.masterJSONPath;
      if (!fs.existsSync(masterJSONPath)) {
        return '';
      }
      relPath = MasterDataResource.getJSONPath(this.relativePath(dirname, cwd));
      return relPath;
    } catch (error) {
      e = error;
      console.error(e);
      return '';
    }
  };


  /**
  get domain files to load
  
  @method getClassFiles
  @private
  @return {Array} filenames
   */

  NonNodeFacadeGenerator.prototype.getClassFiles = function(dirname) {
    var ParentClass, ext, fileInfo, fileInfoDict, filename, files, i, klass, len, name, path, pntFileName, ref, ref1, ref2;
    fileInfoDict = {};
    path = this.absolutePath(dirname);
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

  NonNodeFacadeGenerator.prototype.relativePath = function(path, cwd) {
    var relPath;
    relPath = Path.relative(cwd, path);
    if (relPath.charAt(0) !== '.') {
      relPath = './' + relPath;
    }
    return relPath;
  };

  NonNodeFacadeGenerator.prototype.absolutePath = function(path) {
    if (Path.isAbsolute(path)) {
      return path;
    }
    return process.cwd() + '/' + path;
  };

  return NonNodeFacadeGenerator;

})();

module.exports = NonNodeFacadeGenerator;
