
###*
include submodels

###
class Includer

    ###*
    @constructor
    ###
    constructor: (@model, @modelPool = {}) ->

        @ModelClass = @model.constructor

        @cache(@ModelClass.getName(), @model) if @ModelClass.isEntity


    ###*
    include sub entities

    @method include
    @public
    @param {Object} options
    @param {Boolean} [recursive=false] recursively include or not
    @return {Promise}
    ###
    include: (options = {}) ->

        entityProps = @ModelClass.getEntityProps() 

        promises = []

        for entityProp in entityProps when not @model[entityProp]?

            subModelPromise = @setSubEntity(entityProp)

            promises.push subModelPromise if subModelPromise

        Promise.all(promises).then =>

            if options.recursive
                return @doRecursively()

            return @model


    ###*
    run include for each submodel

    @method doRecursively
    @private
    @return {Promise}
    ###
    doRecursively: ->

        promises = []
        subModelProps = @ModelClass.getModelProps(includeList: true)
        BaseModel = @model.getFacade().constructor.BaseModel

        for modelProp in subModelProps

            subModel = @model[modelProp]

            continue if subModel not instanceof BaseModel

            includer = new Includer(subModel, @modelPool)
            promises.push includer.include(recursive: true)

        return Promise.all(promises).then => @model


    ###*
    load entity by entityProp and set it to @model

    @method setSubEntity
    @private
    @param {String} entityProp
    @return {Promise}
    ###
    setSubEntity: (entityProp) ->

        propInfo = @model.getTypeInfo entityProp

        subId = @model[propInfo.idPropName]

        return if not subId?

        if sub = @cached(propInfo.model, subId)
            @model.set(entityProp, sub)
            return

        repo = @model.getFacade().createRepository(propInfo.model)

        return repo.get(subId).then (subModel) =>
            @model.set entityProp, subModel 
        .catch (e) ->


    ###*
    cache model

    @method cache
    @private
    @param {String} modelName
    @param {Entity} model
    ###
    cache: (modelName, model) ->
        @modelPool[modelName] ?= {}
        @modelPool[modelName][model.id] = model
        return


    ###*
    get cached model

    @method cached
    @private
    @param {String} modelName
    @param {String|Number} id
    @return {Entity} model
    ###
    cached: (modelName, id) ->
        @modelPool[modelName]?[id]



module.exports = Includer
