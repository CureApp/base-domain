var Facade;

Facade = require('./lib/facade');

Facade.fs = require('fs');

Facade.csvParse = require('csv-parse/lib/sync');

module.exports = Facade;
