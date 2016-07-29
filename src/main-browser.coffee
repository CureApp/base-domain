Facade = require('./lib/facade')

fsNotFound = -> throw new Error("module 'fs' is not defined in Browsers.")

Facade.fs =
    existsSync: fsNotFound
    readFileSync: fsNotFound
    writeFileSync: fsNotFound

Facade.requireFile = (file) ->
    throw new Error("requireFile is suppressed in non-node environment. file: #{file}")

Facade.requireJSON = (file) ->
    throw new Error("requireJSON is suppressed in non-node environment. file: #{file}")

module.exports = Facade
