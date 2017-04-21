var Facade, fsNotFound;

Facade = require('./lib/facade');

fsNotFound = function() {
  throw new Error("module 'fs' is not defined in Browsers.");
};

Facade.fs = {
  existsSync: fsNotFound,
  readFileSync: fsNotFound,
  writeFileSync: fsNotFound
};

Facade.requireFile = function(file) {
  throw new Error("requireFile is suppressed in non-node environment. file: " + file);
};

Facade.requireJSON = function(file) {
  throw new Error("requireJSON is suppressed in non-node environment. file: " + file);
};

Facade.csvParse = null;

module.exports = Facade;
