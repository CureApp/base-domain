'use strict';
var DomainError, EntityPool, FixtureLoader, Scope, debug, fs, isPromise, normalize,
  indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

fs = require('fs');

EntityPool = require('./entity-pool');

DomainError = require('./lib/domain-error');

normalize = require('path').normalize;

isPromise = require('./util').isPromise;

debug = require('debug')('base-domain:fixture-loader');


/**
Load fixture data (only works in Node.js)

@class FixtureLoader
@module base-domain
 */

FixtureLoader = (function() {
  function FixtureLoader(facade, fixtureDirs) {
    this.facade = facade;
    this.fixtureDirs = fixtureDirs != null ? fixtureDirs : [];
    if (!Array.isArray(this.fixtureDirs)) {
      this.fixtureDirs = [this.fixtureDirs];
    }
    this.entityPool = new EntityPool;
    this.fixturesByModel = {};
  }


  /**
  @method load
  @public
  @param {Object} [options]
  @param {Boolean} [options.async]
  @return {EntityPool|Promise(EntityPool)}
   */

  FixtureLoader.prototype.load = function(options) {
    var ext, file, fixtureDir, fx, j, k, l, len, len1, len2, modelName, modelNames, names, ref, ref1, ref2, ref3;
    if (options == null) {
      options = {};
    }
    modelNames = [];
    ref = this.fixtureDirs;
    for (j = 0, len = ref.length; j < len; j++) {
      fixtureDir = ref[j];
      ref1 = fs.readdirSync(fixtureDir + '/data');
      for (k = 0, len1 = ref1.length; k < len1; k++) {
        file = ref1[k];
        ref2 = file.split('.'), modelName = ref2[0], ext = ref2[1];
        if (ext !== 'coffee' && ext !== 'js' && ext !== 'json') {
          continue;
        }
        fx = require(fixtureDir + '/data/' + file);
        fx.fixtureDir = fixtureDir;
        this.fixturesByModel[modelName] = fx;
        modelNames.push(modelName);
      }
    }
    modelNames = this.topoSort(modelNames);
    names = (ref3 = options.names) != null ? ref3 : modelNames;
    modelNames = modelNames.filter(function(name) {
      return indexOf.call(names, name) >= 0;
    });
    if (options.async) {
      return this.saveAsync(modelNames).then((function(_this) {
        return function() {
          return _this.entityPool;
        };
      })(this));
    } else {
      for (l = 0, len2 = modelNames.length; l < len2; l++) {
        modelName = modelNames[l];
        this.loadAndSaveModels(modelName);
      }
      return this.entityPool;
    }
  };


  /**
  @private
   */

  FixtureLoader.prototype.saveAsync = function(modelNames) {
    var modelName;
    if (!modelNames.length) {
      return Promise.resolve(true);
    }
    modelName = modelNames.shift();
    return Promise.resolve(this.loadAndSaveModels(modelName)).then((function(_this) {
      return function() {
        return _this.saveAsync(modelNames);
      };
    })(this))["catch"]((function(_this) {
      return function(e) {
        console.error(e.stack);
        return false;
      };
    })(this));
  };


  /**
  @private
   */

  FixtureLoader.prototype.loadAndSaveModels = function(modelName) {
    var PORTION_SIZE, data, e, fx, ids, repo, saveModelsByPortion;
    fx = this.fixturesByModel[modelName];
    data = (function() {
      switch (typeof fx.data) {
        case 'string':
          return this.readTSV(fx.fixtureDir, fx.data);
        case 'function':
          return fx.data.call(new Scope(this, fx), this.entityPool);
        case 'object':
          return fx.data;
      }
    }).call(this);
    try {
      repo = this.facade.createPreferredRepository(modelName);
    } catch (_error) {
      e = _error;
      console.error(e.message);
      return;
    }
    ids = Object.keys(data);
    debug('inserting %s models into %s', ids.length, modelName);
    PORTION_SIZE = 5;
    return (saveModelsByPortion = (function(_this) {
      return function() {
        var id, idsPortion, obj, results;
        if (ids.length === 0) {
          return;
        }
        idsPortion = ids.slice(0, PORTION_SIZE);
        ids = ids.slice(idsPortion.length);
        results = (function() {
          var j, len, results1;
          results1 = [];
          for (j = 0, len = idsPortion.length; j < len; j++) {
            id = idsPortion[j];
            obj = data[id];
            obj.id = id;
            results1.push(this.saveModel(repo, obj));
          }
          return results1;
        }).call(_this);
        if (isPromise(results[0])) {
          return Promise.all(results).then(function() {
            return saveModelsByPortion();
          });
        } else {
          return saveModelsByPortion();
        }
      };
    })(this))();
  };

  FixtureLoader.prototype.saveModel = function(repo, obj) {
    var result;
    result = repo.save(obj, {
      method: 'create',
      fixtureInsertion: true,
      include: {
        entityPool: this.entityPool
      }
    });
    if (isPromise(result)) {
      return result.then((function(_this) {
        return function(entity) {
          return _this.entityPool.set(entity);
        };
      })(this));
    } else {
      return this.entityPool.set(result);
    }
  };


  /**
  topological sort
  
  @method topoSort
  @private
   */

  FixtureLoader.prototype.topoSort = function(names) {
    var add, el, j, k, len, len1, namesWithDependencies, sortedNames, visit, visited;
    namesWithDependencies = [];
    for (j = 0, len = names.length; j < len; j++) {
      el = names[j];
      (add = (function(_this) {
        return function(name) {
          var depname, fx, k, len1, ref, ref1, results1;
          if (indexOf.call(namesWithDependencies, name) >= 0) {
            return;
          }
          namesWithDependencies.push(name);
          fx = _this.fixturesByModel[name];
          if (fx == null) {
            throw new DomainError('base-domain:modelNotFound', "model '" + name + "' is not found. It might be written in some 'dependencies' property.");
          }
          ref1 = (ref = fx.dependencies) != null ? ref : [];
          results1 = [];
          for (k = 0, len1 = ref1.length; k < len1; k++) {
            depname = ref1[k];
            results1.push(add(depname));
          }
          return results1;
        };
      })(this))(el);
    }
    visited = {};
    sortedNames = [];
    for (k = 0, len1 = namesWithDependencies.length; k < len1; k++) {
      el = namesWithDependencies[k];
      (visit = (function(_this) {
        return function(name, ancestors) {
          var depname, fx, l, len2, ref, ref1;
          fx = _this.fixturesByModel[name];
          if (visited[name] != null) {
            return;
          }
          ancestors.push(name);
          visited[name] = true;
          ref1 = (ref = fx.dependencies) != null ? ref : [];
          for (l = 0, len2 = ref1.length; l < len2; l++) {
            depname = ref1[l];
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


  /**
  read TSV, returns model data
  
  @method readTSV
  @private
   */

  FixtureLoader.prototype.readTSV = function(fixtureDir, file) {
    var data, i, id, j, k, len, len1, line, lines, name, names, obj, objs, tsv, value;
    objs = {};
    lines = fs.readFileSync(fixtureDir + '/tsvs/' + file, 'utf8').split('\n');
    tsv = (function() {
      var j, len, results1;
      results1 = [];
      for (j = 0, len = lines.length; j < len; j++) {
        line = lines[j];
        results1.push(line.split('\t'));
      }
      return results1;
    })();
    names = tsv.shift();
    names.shift();
    for (j = 0, len = tsv.length; j < len; j++) {
      data = tsv[j];
      obj = {};
      id = data.shift();
      obj.id = id;
      if (!id) {
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
      objs[obj.id] = obj;
    }
    return objs;
  };

  return FixtureLoader;

})();


/**
'this' property in fixture's data function

this.readTSV('xxx.tsv') is available

    module.exports = {
        data: function(entityPool) {
            this.readTSV('model-name.tsv');
        }
    };

@class Scope
@private
 */

Scope = (function() {
  function Scope(loader, fx1) {
    this.loader = loader;
    this.fx = fx1;
  }


  /**
  @method readTSV
  @param {String} filename filename (directory is automatically set)
  @return {Object} tsv contents
   */

  Scope.prototype.readTSV = function(filename) {
    return this.loader.readTSV(this.fx.fixtureDir, filename);
  };

  return Scope;

})();

module.exports = FixtureLoader;
