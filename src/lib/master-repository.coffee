
BaseRepository  = require './base-repository'

###*
load master data

@abstract
@class MasterRepository
@
###
class MasterRepository extends BaseRepository

    ###*
    loaded map of id => models

    @property modelsById
    @static
    @protected
    ###
    @modelsById: null

    ###*
    loaded map of id => models

    @method getByIdSync
    @public

    @param {String} id
    @return {Model} model
    ###
    getByIdSync: (id) ->

        return null if not @constructor.modelsById? # return null if not loaded

        # TODO determine whether this function returns new instance or reference
        # (now returns reference)
        #return @factory.createFromObject @constructor.modelsById[id]
        return @constructor.modelsById[id] ? null


    ###*
    load whole master data of the model

    @method load
    @return {Promise}
    ###
    @load: ->
        @modelsById = {}

        instance = new @()

        instance.query({}).then (models) =>

            @modelsById[model.id] = model for model in models
            return


module.exports = MasterRepository
