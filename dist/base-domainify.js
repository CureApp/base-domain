var BaseDomainify, coffee, fs, through,
  indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

through = require('through');

fs = require('fs');

coffee = require('coffee-script');

BaseDomainify = (function() {
  BaseDomainify.moduleName = 'base-domain';

  function BaseDomainify() {
    this.initialCodeGenerated = false;
  }


  /**
  get CoffeeScript code of adding addClass methods to all domain files
  
  @method run
  @public
  @return {String} code CoffeeScript code
   */

  BaseDomainify.prototype.run = function(file, options) {
    var data, end, initialCode, write;
    if (options == null) {
      options = {};
    }
    this.dirname = options.dirname;
    if (!this.dirname) {
      this.throwError();
    }
    if (this.initialCodeGenerated) {
      return through();
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
    var _, basename, coffeeCode, filename, i, len, name, path, ref;
    basename = require('path').basename(this.dirname);
    _ = ' ';
    coffeeCode = "Facade = require '" + this.constructor.moduleName + "'\n\nFacade::init = ->\n" + _ + "return unless @dirname.match '" + basename + "'\n";
    ref = this.getFiles();
    for (i = 0, len = ref.length; i < len; i++) {
      filename = ref[i];
      path = this.dirname + '/' + filename;
      name = filename.split('.')[0];
      coffeeCode += _ + "@addClass '" + name + "', require('" + path + "')\n";
    }
    coffeeCode += _ + "return\n";
    return coffee.compile(coffeeCode, {
      bare: true
    });
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
    ref = fs.readdirSync(this.dirname);
    for (i = 0, len = ref.length; i < len; i++) {
      filename = ref[i];
      klass = require(this.dirname + '/' + filename);
      ref1 = filename.split('.'), name = ref1[0], ext = ref1[1];
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
