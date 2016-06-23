'use strict';
var MasterDataResource, MemoryResource, Util;

Util = require('./util');

MemoryResource = require('./memory-resource');


/**

@class MasterDataResource
@implements ResourceClientInterface
 */

MasterDataResource = (function() {

  /**
  load master JSON file if exists
  
  @constructor
   */
  function MasterDataResource(facade) {
    var dirname;
    this.facade = facade;
    dirname = this.facade.dirname;
    this.masterDirPath = this.constructor.getDirPath(dirname);
    this.masterJSONPath = this.constructor.getJSONPath(dirname);
    this.memories = {};
  }


  /**
  Get master data dir
  
  @method getDirPath
  @public
  @static
  @return {String}
   */

  MasterDataResource.getDirPath = function(dirname) {
    return dirname + '/master-data';
  };


  /**
  Get master JSON path
  
  @method getJSONPath
  @public
  @static
  @return {String}
   */

  MasterDataResource.getJSONPath = function(dirname) {
    return this.getDirPath(dirname) + '/all.json';
  };


  /**
  load data from directory(Node.js) or JSON (other environments)
  
  @method init
  @public
  @chainable
   */

  MasterDataResource.prototype.init = function() {
    var modelName, plainMemories, plainMemory;
    if ((typeof Ti === "undefined" || Ti === null) && (typeof window === "undefined" || window === null)) {
      this.build();
    } else {
      plainMemories = this.loadFromJSON();
      for (modelName in plainMemories) {
        plainMemory = plainMemories[modelName];
        this.memories[modelName] = MemoryResource.restore(plainMemory);
      }
    }
    return this;
  };

  MasterDataResource.prototype.initWithData = function(data) {
    var modelName, plainMemory;
    for (modelName in data) {
      plainMemory = data[modelName];
      this.memories[modelName] = MemoryResource.restore(plainMemory);
    }
    return this;
  };


  /**
  load data from JSON file
  This implementation is mainly for Titanium.
  Overwritten by base-domainify when browserify packs into one package.
  
  @method loadFromJSON
  @private
   */

  MasterDataResource.prototype.loadFromJSON = function() {
    var e, error;
    try {
      return Util.requireJSON(this.masterJSONPath);
    } catch (error) {
      e = error;
      return console.error("base-domain: [warning] MasterDataResource could not load from path '" + this.masterJSONPath + "'");
    }
  };


  /**
  Get memory resource of the given modelName
  @method getMemoryResource
  @return {MemoryResource}
   */

  MasterDataResource.prototype.getMemoryResource = function(modelName) {
    var base;
    return (base = this.memories)[modelName] != null ? base[modelName] : base[modelName] = new MemoryResource;
  };


  /**
  Create JSON file from tsv files (**only called by Node.js**)
  
  @method build
   */

  MasterDataResource.prototype.build = function() {
    var FixtureLoader, fs;
    FixtureLoader = require('./fixture-loader');
    new FixtureLoader(this.facade, this.masterDirPath).load();
    fs = this.facade.constructor.fs;
    return fs.writeFileSync(this.masterJSONPath, JSON.stringify(this.toPlainObject(), null, 1));
  };


  /**
  Create plain object
  
  @method toPlainObject
  @return {Object} plainObject
   */

  MasterDataResource.prototype.toPlainObject = function() {
    var memory, modelName, plainObj, ref;
    plainObj = {};
    ref = this.memories;
    for (modelName in ref) {
      memory = ref[modelName];
      plainObj[modelName] = memory.toPlainObject();
    }
    return plainObj;
  };

  return MasterDataResource;

})();

module.exports = MasterDataResource;
