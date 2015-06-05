
module.exports.create = (dirname) ->
    dirname ?= 'empty'
    require('./base-domain').createInstance
        dirname: "#{__dirname}/#{dirname}"
