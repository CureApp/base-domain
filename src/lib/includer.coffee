
###*
include submodels

@class Includer
@module base-domain
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
    @param {Boolean} [async=true] get async values
    @param {Boolean} [recursive=false] recursively include or not
    @param {Array(String)} [props] include only given props
    @return {Promise}
    ###
    include: (@options = {}) ->

        @options.async ?= true

        entityProps = @ModelClass.getEntityProps() 

        if @options.props
            entityProps = (p for p in entityProps when p in @options.props)


        promises = []

        for entityProp in entityProps when not @model[entityProp]?

            subModelPromise = @setSubEntity(entityProp)

            promises.push subModelPromise if subModelPromise

        Promise.all(promises).then =>

            if @options.recursive
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
            promises.push includer.include(@options)

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

        Repository = @model.getFacade().getRepository(propInfo.model)

        repo = new Repository()

        if Repository.isSync
            subModel = repo.get(subId)
            @model.set entityProp, subModel 
            return Promise.resolve subModel

        else
            return unless @options.async

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
