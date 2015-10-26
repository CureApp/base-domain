var BaseDomainify, MasterDataResource, coffee, fs, path, through,
  indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

through = require('through');

fs = require('fs');

path = require('path');

coffee = require('coffee-script');

require('coffee-script/register');

if (path.isAbsolute == null) {
  path.isAbsolute = function(str) {
    return str.charAt(0) === '/';
  };
}

MasterDataResource = require('./master-data-resource');

BaseDomainify = (function() {
  function BaseDomainify(moduleName) {
    this.moduleName = moduleName != null ? moduleName : 'base-domain';
    this.initialCodeGenerated = false;
  }


  /**
  get CoffeeScript code of adding addClass methods to all domain files
  
  @method run
  @public
  @return {String} code CoffeeScript code
   */

  BaseDomainify.prototype.run = function(file, options) {
    var data, dir, dirname, end, initialCode, write;
    if (options == null) {
      options = {};
    }
    if (this.initialCodeGenerated) {
      return through();
    }
    dirname = options.dirname;
    if (!dirname) {
      this.throwError();
    }
    if (path.isAbsolute(dirname)) {
      this.absolutePath = dirname;
    } else {
      this.absolutePath = process.cwd() + '/' + dirname;
    }
    dir = path.dirname(file);
    this.relativePath = path.relative(dir, dirname);
    if (this.relativePath.charAt(0) !== '.') {
      this.relativePath = './' + this.relativePath;
    }
    initialCode = this.getInitialCode(options.dirname);
    this.initialCodeGenerated = true;
    data = '';
    write = function(buf) {
      return data += buf;
    };
    end = function() {
      var i, len, ref, results, val;
      ref = [initialCode, data, null];
      results = [];
      for (i = 0, len = ref.length; i < len; i++) {
        val = ref[i];
        results.push(this.queue(val));
      }
      return results;
    };
    return through(write, end);
  };


  /**
  get CoffeeScript code of adding addClass methods to all domain files
  
  @method getInitialCode
  @private
  @return {String} code CoffeeScript code
   */

  BaseDomainify.prototype.getInitialCode = function() {
    var _, basename, coffeeCode, filename, i, len, masterJSONPath, name, ref;
    basename = require('path').basename(this.relativePath);
    _ = ' ';
    coffeeCode = "Facade = require '" + this.moduleName + "'\n\nFacade::init = ->\n" + _ + "return unless @dirname.match '" + basename + "'\n";
    if (masterJSONPath = this.getMasterJSONPath()) {
      coffeeCode += _ + "@master?.loadFromJSON = -> require('" + masterJSONPath + "')\n";
    }
    ref = this.getFiles();
    for (i = 0, len = ref.length; i < len; i++) {
      filename = ref[i];
      name = filename.split('.')[0];
      path = this.relativePath + '/' + name;
      coffeeCode += _ + "@addClass require('" + path + "')\n";
    }
    coffeeCode += _ + "return\n";
    return coffee.compile(coffeeCode, {
      bare: true
    });
  };


  /**
  @method getCodeOfMasterData
  @private
  @return {String} path
   */

  BaseDomainify.prototype.getMasterJSONPath = function() {
    var e, master, masterJSONPath, relPath;
    master = new MasterDataResource(this.absolutePath);
    try {
      master.build();
      masterJSONPath = master.masterJSONPath;
      if (!fs.existsSync(masterJSONPath)) {
        return '';
      }
      relPath = new MasterDataResource(this.relativePath).masterJSONPath;
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

  BaseDomainify.prototype.getFiles = function() {
    var ParentClass, ext, fileInfo, fileInfoDict, filename, files, i, klass, len, name, pntFileName, ref, ref1, ref2;
    fileInfoDict = {};
    ref = fs.readdirSync(this.absolutePath);
    for (i = 0, len = ref.length; i < len; i++) {
      filename = ref[i];
      ref1 = filename.split('.'), name = ref1[0], ext = ref1[1];
      if (ext !== 'js' && ext !== 'coffee') {
        continue;
      }
      klass = require(this.absolutePath + '/' + filename);
      if (typeof klass.getName !== 'function') {
        continue;
      }
      if (klass.getName() !== name) {
        continue;
      }
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
      if (typeof ParentClass.getName === 'function' && (pntFileName = (ref2 = fileInfoDict[ParentClass.getName()]) != null ? ref2.filename : void 0)) {
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
    throw new Error("dirname must be passed.\n\nbrowserify -t [ base-domain/ify --dirname dirname ]\n");
  };

  return BaseDomainify;

})();

module.exports = BaseDomainify;
