var FixtureLoader, fs;

fs = require('fs');


/**
Load fixture data (only works in Node.js)

@class FixtureLoader
@module base-domain
 */

FixtureLoader = (function() {
  function FixtureLoader(fixtureDir) {
    this.fixtureDir = fixtureDir;
  }


  /**
  @method load
  @public
   */

  FixtureLoader.prototype.load = function() {
    var ext, file, j, len, modelName, ref, ref1, tables;
    tables = {};
    ref = fs.readdirSync(this.fixtureDir + '/data');
    for (j = 0, len = ref.length; j < len; j++) {
      file = ref[j];
      ref1 = file.split('.'), modelName = ref1[0], ext = ref1[1];
      tables[modelName] = this.loadFile(file);
    }
    return tables;
  };


  /**
  load one data file
  
  @method loadFile
  @private
   */

  FixtureLoader.prototype.loadFile = function(file) {
    var data, ext, modelName, ref;
    ref = file.split('.'), modelName = ref[0], ext = ref[1];
    data = require(this.fixtureDir + '/data/' + file).data;
    switch (typeof data) {
      case 'string':
        return this.readTSV(data);
      case 'function':
        return data.call(this, {});
      case 'object':
        return data;
    }
  };


  /**
  read TSV, returns model data
  
  @method readTSV
  @private
   */

  FixtureLoader.prototype.readTSV = function(file) {
    var data, i, id, j, k, len, len1, line, lines, name, names, obj, objs, tsv, value;
    objs = {};
    lines = fs.readFileSync(this.fixtureDir + '/tsvs/' + file, 'utf8').split('\n');
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
