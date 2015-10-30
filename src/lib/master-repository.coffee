

BaseSyncRepository = require './base-sync-repository'

###*
Master repository: handling static data
Master data are loaded from master-data directory (by default, it's facade.dirname + /master-data)
These data should be formatted in Fixture.
Master data are read-only, so 'save', 'update' and 'delete' methods are not available.
(And currently, 'query' and 'singleQuery' are also unavailable as MemoryResource does not support them yet...)

@class MasterRepository
@extends BaseSyncRepository
@module base-domain
###
class MasterRepository extends BaseSyncRepository


    ###*
    Name of the data in master data.
    @modelName is used if not set.

    @property {String} dataName
    @static
    ###
    @dataName: null


    constructor: ->

        super

        { master } =  @getFacade()

        if not master?
            throw @error('masterNotFound', """
                MasterRepository is disabled by default.
                To enable it, set the option to Facade.createInstance() like

                Facade.createInstance(master: true)
            """)

        dataName = @constructor.dataName ? @constructor.modelName

        @client = master.getMemoryResource(dataName)


    ###*
    Update or insert a model instance
    Save data with force option. Otherwise throw an error.

    @method save
    @public
    ###
    save: (data, options = {}) ->
        if options.force
            super(data, options)
        else
            throw @error('cannotSaveWithMasterRepository', 'base-domain:cannot save with MasterRepository')


    ###*
    Destroy the given entity (which must have "id" value)

    @method delete
    @public
    @param {Entity} entity
    @param {ResourceClientInterface} [client=@client]
    @return {Boolean} isDeleted
    ###
    delete: ->
        throw @error('cannotDeleteWithMasterRepository', 'base-domain:cannot delete with MasterRepository')

    ###*
    Update set of attributes.

    @method update
    @public
    @param {String|Number} id of the entity to update
    @param {Object} data key-value pair to update (notice: this must not be instance of Entity)
    @param {ResourceClientInterface} [client=@client]
    @return {Entity} updated entity
    ###
    update: ->
        throw @error('cannotUpdateWithMasterRepository', 'base-domain:cannot update with MasterRepository')

module.exports = MasterRepository
