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
  function MasterDataResource(domainPath) {
    this.masterDirPath = domainPath + '/master-data';
    this.masterJSONPath = this.masterDirPath + '/all.json';
    this.memories = {};
  }


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


  /**
  load data from JSON file
  This implementation is mainly for Titanium.
  Overwritten by base-domainify when browserify packs into one package.
  
  @method loadFromJSON
  @private
   */

  MasterDataResource.prototype.loadFromJSON = function() {
    var e;
    try {
      return Util.requireJSON(this.masterJSONPath);
    } catch (_error) {
      e = _error;
      return console.error("base-domain: [warning] MasterDataResource could not load from path '" + this.masterJSONPath + "'");
    }
  };


  /**
  Get memory resource of the given modelName
  @method getMemoryResource
  @return {MemoryResource}
   */

  MasterDataResource.prototype.getMemoryResource = function(modelName) {
    return this.memories[modelName];
  };


  /**
  Create JSON file from tsv files (**only called by Node.js**)
  
  @method build
   */

  MasterDataResource.prototype.build = function() {
    var FixtureLoader, data, fs, id, memory, modelData, modelName, value;
    FixtureLoader = require('./fixture-loader');
    data = new FixtureLoader(this.masterDirPath).load();
    for (modelName in data) {
      modelData = data[modelName];
      memory = this.memories[modelName] = new MemoryResource();
      for (id in modelData) {
        value = modelData[id];
        memory.create(value);
      }
    }
    fs = require('fs');
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
