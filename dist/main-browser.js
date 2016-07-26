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

module.exports = Facade;
