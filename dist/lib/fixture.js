var DomainError, Fixture, FixtureModel, debug, fs, normalize,
  indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

DomainError = require('./domain-error');

debug = null;

normalize = require('path').normalize;

fs = require('fs');


/**
load data from directory and generates fixtures
only available in Node.js

@class Fixture
@module base-domain
 */

Fixture = (function() {

  /**
  @constructor
  @param {Object} [options]
  @param {String|Array} [options.dirname='./fixtures'] director(y|ies) to have fixture files. /data, /tsvs should be included in the directory.
  @param {Object} [options.data={}] default data, merged to dataPool
  @param {String} [options.debug] if true, shows debug log
   */
  function Fixture(facade, options) {
    var base, dataDir, debugMode, dirname, dirnames, ext, file, j, k, len, len1, modelName, ref, ref1, ref2, setting;
    this.facade = facade;
    if (options == null) {
      options = {};
    }
    debugMode = (ref = options.debug) != null ? ref : !!this.facade.debug;
    if (debugMode) {
      require('debug').enable('base-domain:fixture');
    }
    debug = require('debug')('base-domain:fixture');
    this.fxModelMap = {};
    dirnames = options.dirname != null ? Array.isArray(options.dirname) ? options.dirname : [options.dirname] : [__dirname + '/fixtures'];
    for (j = 0, len = dirnames.length; j < len; j++) {
      dirname = dirnames[j];
      dataDir = normalize(dirname + '/data');
      ref1 = fs.readdirSync(dataDir);
      for (k = 0, len1 = ref1.length; k < len1; k++) {
        file = ref1[k];
        ref2 = file.split('.'), modelName = ref2[0], ext = ref2[1];
        if (ext !== 'js' && ext !== 'coffee' && ext !== 'json') {
          continue;
        }
        setting = require(dataDir + '/' + file);
        this.fxModelMap[modelName] = new FixtureModel(this, modelName, setting, normalize(dirname));
      }
    }
    this.dataPool = (options.data != null) && typeof options.data === 'object' ? JSON.parse(JSON.stringify(options.data)) : {};
    for (modelName in this.fxModelMap) {
      if ((base = this.dataPool)[modelName] == null) {
        base[modelName] = {};
      }
    }
  }


  /**
  add data to pool for model's data
  
  @method addToDataPool
  @return {Object}
   */

  Fixture.prototype.addToDataPool = function(modelName, dataName, data) {
    return this.dataPool[modelName][dataName] = data;
  };


  /**
  inserts data to datasource
  
  @param {Array} names list of fixture models to insert data
  @method insert
  @return {Promise}
   */

  Fixture.prototype.insert = function(names) {
    var insert, modelNames, name;
    if (names == null) {
      names = (function() {
        var results;
        results = [];
        for (name in this.fxModelMap) {
          results.push(name);
        }
        return results;
      }).call(this);
    }
    if (typeof names === 'string') {
      names = [names];
    }
    modelNames = this.resolveDependencies(names);
    if (!modelNames.length) {
      debug('no data to insert.');
      return Promise.resolve(true);
    }
    debug("insertion order: " + (modelNames.join(' -> ')));
    return (insert = (function(_this) {
      return function() {
        var fxModel, modelName;
        modelName = modelNames.shift();
        if (modelName == null) {
          return Promise.resolve(true);
        }
        fxModel = _this.fxModelMap[modelName];
        return fxModel.insert().then(function() {
          return insert();
        })["catch"](function(e) {
          console.error(e.stack);
          return false;
        });
      };
    })(this))();
  };


  /**
  adds dependent models, topological sort
  
  @private
  @param {Array} names list of fixture models to insert data
  @method resolveDependencies
  @return {Array} model names
   */

  Fixture.prototype.resolveDependencies = function(names) {
    var add, el, j, k, len, len1, namesWithDependencies, sortedNames, visit, visited;
    namesWithDependencies = [];
    for (j = 0, len = names.length; j < len; j++) {
      el = names[j];
      (add = (function(_this) {
        return function(name) {
          var depname, fxModel, k, len1, ref, results;
          if (indexOf.call(namesWithDependencies, name) >= 0) {
            return;
          }
          namesWithDependencies.push(name);
          fxModel = _this.fxModelMap[name];
          if (!fxModel) {
            throw new DomainError('base-domain:modelNotFound', "model '" + name + "' is not found. It might be written in some 'dependencies' property.");
          }
          ref = fxModel.dependencies;
          results = [];
          for (k = 0, len1 = ref.length; k < len1; k++) {
            depname = ref[k];
            results.push(add(depname));
          }
          return results;
        };
      })(this))(el);
    }
    visited = {};
    sortedNames = [];
    for (k = 0, len1 = namesWithDependencies.length; k < len1; k++) {
      el = namesWithDependencies[k];
      (visit = (function(_this) {
        return function(name, ancestors) {
          var depname, fxModel, l, len2, ref;
          fxModel = _this.fxModelMap[name];
          if (visited[name] != null) {
            return;
          }
          ancestors.push(name);
          visited[name] = true;
          ref = fxModel.dependencies;
          for (l = 0, len2 = ref.length; l < len2; l++) {
            depname = ref[l];
            if (indexOf.call(ancestors, depname) >= 0) {
              throw new DomainError('base-domain:dependencyLoop', 'dependency chain is making loop');
            }
            visit(depname, ancestors.slice());
          }
          return sortedNames.push(name);
        };
      })(this))(el, []);
    }
    return sortedNames;
  };

  return Fixture;

})();


/**

@class FixtureModel
 */

FixtureModel = (function() {

  /**
  @constructor
   */
  function FixtureModel(fx, name1, setting, dirname1) {
    var ref, ref1;
    this.fx = fx;
    this.name = name1;
    if (setting == null) {
      setting = {};
    }
    this.dirname = dirname1;
    this.dependencies = (ref = setting.dependencies) != null ? ref : [];
    this.data = (ref1 = setting.data) != null ? ref1 : function() {};
  }


  /**
  inserts data to datasource
  
  @method insert
  @return {Promise}
   */

  FixtureModel.prototype.insert = function() {
    var dataNames, insert, modelDataMap, repository;
    modelDataMap = (function() {
      switch (typeof this.data) {
        case 'string':
          return this.readTSV(this.data);
        case 'function':
          return this.data(this.fx.dataPool);
      }
    }).call(this);
    dataNames = Object.keys(modelDataMap);
    debug("inserting " + dataNames.length + " data into " + this.name);
    repository = this.fx.facade.createRepository(this.name);
    return (insert = (function(_this) {
      return function() {
        var data, dataName;
        if (dataNames.length === 0) {
          return Promise.resolve(true);
        }
        dataName = dataNames.shift();
        data = modelDataMap[dataName];
        return Promise.resolve(repository.save(data)).then(function(savedModel) {
          _this.fx.addToDataPool(_this.name, dataName, savedModel);
          return insert();
        });
      };
    })(this))();
  };


  /**
  read TSV, returns model data
  
  @method readTSV
   */

  FixtureModel.prototype.readTSV = function(filename) {
    var data, dataName, i, j, k, len, len1, line, lines, name, names, obj, objs, tsv, value;
    objs = {};
    lines = fs.readFileSync(this.dirname + '/tsvs/' + filename, 'utf8').split('\n');
    tsv = (function() {
      var j, len, results;
      results = [];
      for (j = 0, len = lines.length; j < len; j++) {
        line = lines[j];
        results.push(line.split('\t'));
      }
      return results;
    })();
    names = tsv.shift();
    names.shift();
    for (j = 0, len = tsv.length; j < len; j++) {
      data = tsv[j];
      obj = {};
      dataName = data.shift();
      if (!dataName) {
        break;
      }
      for (i = k = 0, len1 = names.length; k < len1; i = ++k) {
        name = names[i];
        if (!name) {
          break;
        }
        value = data[i];
        if (value.match(/^[0-9]+$/)) {
          value = Number(value);
        }
        obj[name] = value;
      }
      objs[dataName] = obj;
    }
    return objs;
  };

  return FixtureModel;

})();

module.exports = Fixture;