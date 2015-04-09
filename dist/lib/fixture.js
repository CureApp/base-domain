var Fixture, FixtureModel, Promise, fs,
  indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

fs = require('fs');

Promise = require('es6-promise').Promise;


/**

@class Fixture
 */

Fixture = (function() {

  /**
  @constructor
  @param {Object} [options]
  @param {String} [options.dirname='./fixtures'] directory to have fixture files. /data, /tsvs should be included in the directory.
  @param {String} [options.debug] if true, shows debug log
   */
  function Fixture(facade, options) {
    var file, files, j, len, modelName, ref, ref1, setting;
    this.facade = facade;
    if (options == null) {
      options = {};
    }
    this.debug = (ref = options.debug) != null ? ref : !!this.facade.debug;
    this.fxModelMap = {};
    this.dirname = (ref1 = options.dirname) != null ? ref1 : __dirname + '/fixtures';
    files = fs.readdirSync(this.dirname + '/data');
    for (j = 0, len = files.length; j < len; j++) {
      file = files[j];
      modelName = file.split('.').shift();
      setting = require(this.dirname + '/data/' + file);
      this.fxModelMap[modelName] = new FixtureModel(this, modelName, setting);
    }
    this.dataPool = {};
    for (modelName in this.fxModelMap) {
      this.dataPool[modelName] = {};
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
  inserts data in LoopBack
  
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
      if (this.debug) {
        console.log('no data to insert.');
      }
      return Promise.resolve(true);
    }
    if (this.debug) {
      console.log('insertion order');
    }
    if (this.debug) {
      console.log("\t" + (modelNames.join(' -> ')) + "\n");
    }
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
            throw new Error("model '" + name + "' is not found. It might be written in some 'dependencies' property.");
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
              throw new Error('dependency chain is making loop');
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
  function FixtureModel(fx, name1, setting) {
    var ref, ref1;
    this.fx = fx;
    this.name = name1;
    if (setting == null) {
      setting = {};
    }
    this.dependencies = (ref = setting.dependencies) != null ? ref : [];
    this.data = (ref1 = setting.data) != null ? ref1 : function() {};
  }


  /**
  inserts data in LoopBack
  
  @method insert
  @return {Promise}
   */

  FixtureModel.prototype.insert = function() {
    var dataNames, factory, insert, modelDataMap, repository;
    modelDataMap = (function() {
      switch (typeof this.data) {
        case 'string':
          return this.readTSV(this.data);
        case 'function':
          return this.data(this.fx.dataPool);
      }
    }).call(this);
    dataNames = Object.keys(modelDataMap);
    if (this.fx.debug) {
      console.log("inserting " + dataNames.length + " data into " + this.name);
    }
    factory = this.fx.facade.createFactory(this.name);
    repository = this.fx.facade.createRepository(this.name, {
      debug: false
    });
    return (insert = (function(_this) {
      return function() {
        var data, dataName, model;
        if (dataNames.length === 0) {
          return Promise.resolve(true);
        }
        dataName = dataNames.shift();
        data = modelDataMap[dataName];
        model = factory.createFromObject(data);
        return repository.save(model).then(function(savedModel) {
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
    lines = fs.readFileSync(this.fx.dirname + '/tsvs/' + filename, 'utf8').split('\n');
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
