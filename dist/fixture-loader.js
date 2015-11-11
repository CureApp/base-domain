var DomainError, EntityPool, FixtureLoader, debug, fs, normalize,
  indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

fs = require('fs');

EntityPool = require('./entity-pool');

DomainError = require('./lib/domain-error');

normalize = require('path').normalize;

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
    return Promise.all(this.loadAndSaveModels(modelName)).then((function(_this) {
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
    var data, e, fx, id, obj, repo, results;
    fx = this.fixturesByModel[modelName];
    data = (function() {
      switch (typeof fx.data) {
        case 'string':
          return this.readTSV(fx.fixtureDir, fx.data);
        case 'function':
          return fx.data(this.entityPool);
        case 'object':
          return fx.data;
      }
    }).call(this);
    try {
      repo = this.facade.createRepository(modelName);
    } catch (_error) {
      e = _error;
      console.error(e.message);
      return;
    }
    debug('inserting %s models into %s', Object.keys(data).length, modelName);
    results = [];
    for (id in data) {
      obj = data[id];
      obj.id = id;
      results.push(repo.save(obj, {
        method: 'create',
        force: true,
        include: {
          entityPool: this.entityPool
        }
      }));
    }
    return results;
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
          var depname, fx, k, len1, ref, ref1, results;
          if (indexOf.call(namesWithDependencies, name) >= 0) {
            return;
          }
          namesWithDependencies.push(name);
          fx = _this.fixturesByModel[name];
          if (fx == null) {
            throw new DomainError('base-domain:modelNotFound', "model '" + name + "' is not found. It might be written in some 'dependencies' property.");
          }
          ref1 = (ref = fx.dependencies) != null ? ref : [];
          results = [];
          for (k = 0, len1 = ref1.length; k < len1; k++) {
            depname = ref1[k];
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

module.exports = FixtureLoader;
