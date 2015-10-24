
###*
parses model properties and classifies them

@class ModelProps
@module base-domain
###
class ModelProps

    constructor: (@modelName, properties, facade) ->

        ###*
        property whose type is CREATED_AT
        @property {String} createdAt
        ###
        @createdAt = null

        ###*
        property whose type is UPDATED_AT
        @property {String} updatedAt
        ###
        @updatedAt = null

        ###*
        properties whose type is MODEL, MODEL_LIST, MODEL_DICT
        @property {Array(String)} models
        ###
        @models = []

        ###*
        properties whose type is MODEL and the model extends Entity
        @property {Array(String)} entities
        ###
        @entities = []

        ###*
        properties whose type is DATE, CREATED_AT and UPDATED_AT
        @property {Array(String)} dates
        ###
        @dates = []

        ###*
        properties whose type is MODEL and the model does not extend Entity
        @property {Array(String)} nonEntities
        ###
        @nonEntities = []

        ###*
        key value pairs of (property => TypeInfo)
        @property {Object(TypeInfo)} dic
        ###
        @dic = {}

        # private
        @entityDic = {}
        @modelDic  = {}
        @tmpDic    = {}
        @idDic     = {}


        @build properties, facade


    ###*
    classify each prop by type

    @method build
    @private
    ###
    build: (properties, facade) ->

        for prop, typeInfo of properties

            @dic[prop] = typeInfo

            if typeInfo.tmp
                @tmpDic[prop] = true

            switch typeInfo.name
                when 'DATE'
                    @dates.push prop

                when 'CREATED_AT'
                    @createdAt = prop
                    @dates.push prop

                when 'UPDATED_AT'
                    @updatedAt = prop
                    @dates.push prop

                when 'MODEL', 'MODEL_LIST', 'MODEL_DICT'
                    @models.push prop
                    @modelDic[prop] = true

                    if not facade?

                        console.error("""
                            base-domain:ModelProps could not parse property info of '#{prop}'.
                            (@TYPES.#{typeInfo.name}, model=#{typeInfo.model}.)
                            Construct original model '#{@modelName}' with RootInterface.

                                new Model(obj, facade)
                                facade.createModel('#{@modelName}', obj)

                        """)
                        continue

                    if facade.getModel(typeInfo.model).isEntity
                        @entities.push prop
                        @entityDic[prop] = true
                        @idDic[typeInfo.idPropName] = prop
                    else
                        @nonEntities.push prop

        return


    names: ->
        Object.keys @dic


    types: ->
        (typeInfo for prop, typeInfo of @dic)


    ###*
    check if the given prop is entity prop

    @method isEntity
    @param {String} prop
    @return {Boolean}
    ###
    isEntity: (prop) ->
        return @entityDic[prop]?


    ###*
    check if the given prop is submodel's id

    @method isId
    @param {String} prop
    @return {Boolean}
    ###
    isId: (prop) ->
        return @idDic[prop]?


    ###*
    get submodel prop of the given idPropName

    @method submodelOf
    @param {String} idPropName
    @return {String} submodelProp
    ###
    submodelOf: (idPropName) ->
        return @idDic[idPropName]

    ###*
    get typeInfo by prop

    @method getTypeInfo
    @param {String} prop
    @return {TypeInfo}
    ###
    getTypeInfo: (prop) ->
        return @dic[prop]


    ###*
    check if the given prop is model prop

    @method isModel
    @param {String} prop
    @return {Boolean}
    ###
    isModel: (prop) ->
        return @modelDic[prop]?

    ###*
    check if the given prop is tmp prop

    @method isTmp
    @param {String} prop
    @return {Boolean}
    ###
    isTmp: (prop) ->
        return @tmpDic[prop]?


module.exports = ModelProps
