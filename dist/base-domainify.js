'use strict';
var BaseDomainify, Facade, MasterDataResource, Path, coffee, fs, through,
  indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

through = require('through');

fs = require('fs');

Path = require('path');

coffee = require('coffee-script');

require('coffee-script/register');

if (Path.isAbsolute == null) {
  Path.isAbsolute = function(str) {
    return str.charAt(0) === '/';
  };
}

Facade = require('./lib/facade');

MasterDataResource = require('./master-data-resource');

BaseDomainify = (function() {
  function BaseDomainify(moduleName1) {
    this.moduleName = moduleName1 != null ? moduleName1 : 'base-domain';
    this.initialCodeGenerated = false;
  }


  /**
  get CoffeeScript code of adding addClass methods to all domain files
  
  @method run
  @public
  @return {String} code CoffeeScript code
   */

  BaseDomainify.prototype.run = function(file, options) {
    var data, dirname, end, i, initialCode, len, modName, modNamePath, modulePaths, modules, path, ref, ref1, ref2, write;
    this.file = file;
    if (options == null) {
      options = {};
    }
    if (this.initialCodeGenerated) {
      return through();
    }
    dirname = options.dirname, modules = options.modules;
    if (!dirname) {
      this.throwError();
    }
    modulePaths = {};
    ref1 = (ref = modules != null ? modules.split(',') : void 0) != null ? ref : [];
    for (i = 0, len = ref1.length; i < len; i++) {
      modNamePath = ref1[i];
      ref2 = modNamePath.split(':'), modName = ref2[0], path = ref2[1];
      modulePaths[modName] = path;
    }
    initialCode = this.getInitialCode(dirname, modulePaths);
    this.initialCodeGenerated = true;
    data = '';
    write = function(buf) {
      return data += buf;
    };
    end = function() {
      var j, len1, ref3, results, val;
      ref3 = [initialCode, data, null];
      results = [];
      for (j = 0, len1 = ref3.length; j < len1; j++) {
        val = ref3[j];
        results.push(this.queue(val));
      }
      return results;
    };
    return through(write, end);
  };

  BaseDomainify.prototype.relativePath = function(path) {
    var dir, relPath;
    dir = Path.dirname(this.file);
    relPath = Path.relative(dir, path);
    if (relPath.charAt(0) !== '.') {
      relPath = './' + relPath;
    }
    return relPath;
  };

  BaseDomainify.prototype.absolutePath = function(path) {
    if (Path.isAbsolute(path)) {
      return path;
    }
    return process.cwd() + '/' + path;
  };

  BaseDomainify.prototype.baseName = function(path) {
    return Path.basename(path);
  };


  /**
  get CoffeeScript code of adding addClass methods to all domain files
  
  @method getInitialCode
  @private
  @return {String} code CoffeeScript code
   */

  BaseDomainify.prototype.getInitialCode = function(dirname, modulePaths) {
    var _, basename, coffeeCode, moduleName, path;
    basename = this.baseName(dirname);
    _ = ' ';
    coffeeCode = "Facade = require '" + this.moduleName + "'\n\nFacade::init = ->\n" + _ + "return unless @dirname.match '" + basename + "'\n";
    coffeeCode += this.getScriptToLoadCoreModule(dirname);
    for (moduleName in modulePaths) {
      path = modulePaths[moduleName];
      coffeeCode += this.getScriptToLoadModule(moduleName, path);
    }
    coffeeCode += _ + "return\n";
    return coffee.compile(coffeeCode, {
      bare: true
    });
  };

  BaseDomainify.prototype.getScriptToLoadCoreModule = function(dirname) {
    var _, coffeeCode, filename, i, len, masterJSONPath, name, path, ref;
    _ = ' ';
    coffeeCode = '';
    if (masterJSONPath = this.getMasterJSONPath(dirname)) {
      coffeeCode += _ + "@master?.loadFromJSON = -> require('" + masterJSONPath + "')\n";
    }
    ref = this.getFiles(dirname);
    for (i = 0, len = ref.length; i < len; i++) {
      filename = ref[i];
      name = filename.split('.')[0];
      path = this.relativePath(dirname) + '/' + name;
      coffeeCode += _ + "@addClass '" + name + "', require('" + path + "')\n";
    }
    return coffeeCode;
  };

  BaseDomainify.prototype.getScriptToLoadModule = function(moduleName, moduleDirname) {
    var _, basename, coffeeCode, filename, i, len, name, path, ref;
    basename = this.baseName(moduleDirname);
    _ = ' ';
    coffeeCode = _ + "if @modules['" + moduleName + "'] and @modules['" + moduleName + "'].path.match '" + basename + "'\n";
    ref = this.getFiles(moduleDirname);
    for (i = 0, len = ref.length; i < len; i++) {
      filename = ref[i];
      name = filename.split('.')[0];
      path = this.relativePath(moduleDirname) + '/' + name;
      coffeeCode += "" + _ + _ + "@addClass '" + moduleName + "/" + name + "', require('" + path + "')\n";
    }
    return coffeeCode;
  };


  /**
  @method getCodeOfMasterData
  @private
  @return {String} path
   */

  BaseDomainify.prototype.getMasterJSONPath = function(dirname) {
    var e, facade, masterJSONPath, relPath;
    try {
      facade = Facade.createInstance({
        dirname: this.absolutePath(dirname),
        master: true
      });
      masterJSONPath = facade.master.masterJSONPath;
      if (!fs.existsSync(masterJSONPath)) {
        return '';
      }
      relPath = MasterDataResource.getJSONPath(this.relativePath(dirname));
      return relPath;
    } catch (_error) {
      e = _error;
      return '';
    }
  };


  /**
  get domain files to load
  
  @method getFiles
  @private
  @return {Array} filenames
   */

  BaseDomainify.prototype.getFiles = function(dirname) {
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
      klass = require(path + '/' + filename);
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
  throw error
  
  @method throwError
  @private
   */

  BaseDomainify.prototype.throwError = function() {
    throw new Error("dirname must be passed.\n\nbrowserify -t [ base-domain/ify --dirname dirname --modules module1:/path/to/module1,module2:/path/to/module2 ]\n");
  };

  return BaseDomainify;

})();

module.exports = BaseDomainify;
