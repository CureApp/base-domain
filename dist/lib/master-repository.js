var BaseRepository, MasterRepository,
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

BaseRepository = require('./base-repository');


/**
load master data

@abstract
@class MasterRepository
@
 */

MasterRepository = (function(superClass) {
  extend(MasterRepository, superClass);

  function MasterRepository() {
    return MasterRepository.__super__.constructor.apply(this, arguments);
  }


  /**
  a flag to load and store all models with @load() method
  if set to true, master table is generated after @load() method,
  and used in BaseFactory#createFromObject()
  
  @property storeMasterTable
  @static
  @type Boolean
   */

  MasterRepository.storeMasterTable = true;


  /**
  loaded map of id => models
  
  @property modelsById
  @static
  @protected
   */

  MasterRepository.modelsById = null;


  /**
  check loaded or not
  
  @method loaded
  @static
  @public
   */

  MasterRepository.loaded = function() {
    return this.modelsById != null;
  };


  /**
  get model by id
  
  @method getByIdSync
  @public
  
  @param {String} id
  @return {Model} model
   */

  MasterRepository.prototype.getByIdSync = function(id) {
    var ref;
    if (this.constructor.modelsById == null) {
      return null;
    }
    return (ref = this.constructor.modelsById[id]) != null ? ref : null;
  };


  /**
  load whole master data of the model
  when @storeMasterTable is off, load will fail.
  
  @method load
  @return {Promise(Boolean)} is load succeed or not.
   */

  MasterRepository.load = function() {
    var instance;
    if (!this.storeMasterTable) {
      return Promise.resolve(false);
    }
    this.modelsById = {};
    instance = new this();
    return instance.query({}).then((function(_this) {
      return function(models) {
        var i, len, model;
        for (i = 0, len = models.length; i < len; i++) {
          model = models[i];
          _this.modelsById[model.id] = model;
        }
        return true;
      };
    })(this));
  };

  return MasterRepository;

})(BaseRepository);

module.exports = MasterRepository;
