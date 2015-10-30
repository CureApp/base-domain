
module.exports.create = (dirname, options = {}) ->
    options.dirname =  __dirname + '/' + dirname ? 'empty'
    require('./base-domain').createInstance options
