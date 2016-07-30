Facade = require('./lib/facade')

fsNotFound = -> throw new Error("module 'fs' is not defined in Browsers.")

Facade.fs =
    existsSync: fsNotFound
    readFileSync: fsNotFound
    writeFileSync: fsNotFound

Facade.csvParse = null

module.exports = Facade
