fs  = require 'fs'
ECT = require 'ect'

renderer = ECT root: __dirname + '/../templates'


createScripts = (modelName, dirname, options = {}) ->

    unless modelName
        console.error """
            usage
            $ base-domain <model-name> [dirname=.]
        """
        return


    dirname ?= '.'

    ModelName = (name.charAt(0).toUpperCase() + name.slice(1) for name in modelName.split('-')).join('')


    console.log "generating #{dirname}/#{modelName}.coffee"
    fs.writeFileSync "#{dirname}/#{modelName}.coffee", renderer.render('entity.coffee', model: modelName, Model: ModelName)


    console.log "generating #{dirname}/#{modelName}-factory.coffee"
    fs.writeFileSync "#{dirname}/#{modelName}-factory.coffee", renderer.render('factory.coffee', model: modelName, Model: ModelName)


    console.log "generating #{dirname}/#{modelName}-repository.coffee"
    fs.writeFileSync "#{dirname}/#{modelName}-repository.coffee", renderer.render('repository.coffee', model: modelName, Model: ModelName)


module.exports = createScripts
