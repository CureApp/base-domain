facade = require('./lib/custom-facade').createInstance
    dirname: __dirname + '/domain'
    master: true
    modules:
        cli: __dirname + '/domain/client'
        web: __dirname + '/domain/web'

module.exports = facade
