
BaseRepository  = require './base-repository'
Promise = require('es6-promise').Promise

###*
load master data

@abstract
@class MasterRepository
@
###
class MasterRepository extends BaseRepository

    ###*
    a flag to load and store all models with @load() method
    if set to true, master table is generated after @load() method,
    and used in BaseFactory#createFromObject()

    @property storeMasterTable
    @static
    @type Boolean
    ###
    @storeMasterTable: on


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
    when @storeMasterTable is off, load will fail.

    @method load
    @return {Promise(Boolean)} is load succeed or not.
    ###
    @load: ->

        return Promise.resolve(false) if not @storeMasterTable

        @modelsById = {}

        instance = new @()

        instance.query({}).then (models) =>

            @modelsById[model.id] = model for model in models
            return true


module.exports = MasterRepository
