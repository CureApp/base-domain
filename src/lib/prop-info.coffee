
###*
parses model properties and classifies them

@class PropInfo
@module base-domain
###
class PropInfo

    constructor: (props, facade) ->

        ###*
        property whose type is CREATED_AT
        @property createdAt
        @type String
        ###
        @createdAt = null

        ###*
        property whose type is UPDATED_AT
        @property updatedAt
        @type String
        ###
        @updatedAt = null

        ###*
        properties whose type is MODEL
        @property modelProps
        @type Array
        ###
        @modelProps  = []

        ###*
        properties whose type is MODEL_LIST
        @property listProps
        @type Array
        ###
        @listProps  = []

        ###*
        properties whose type is MODEL and the model extends Entity
        @property entityProps
        @type Array
        ###
        @entityProps = []

        ###*
        properties whose type is DATE, CREATED_AT and UPDATED_AT
        @property dateProps
        @type Array
        ###
        @dateProps = []


        ###*
        properties whose type is MODEL and the model does not extend Entity
        @property nonEntityProps
        @type Array
        ###
        @nonEntityProps = []

        ###*
        key value pairs of (property => TypeInfo)
        @property dic
        @type Object
        ###
        @dic = {}


        # private
        @entityDic = {}
        @modelDic = {}


        @build props, facade


    ###*
    classify each prop by type

    @method build
    @private
    ###
    build: (props, facade) ->

        for prop, typeInfo of props

            @dic[prop] = typeInfo

            switch typeInfo.name
                when 'DATE'
                    @dateProps.push prop

                when 'CREATED_AT'
                    @createdAt = prop
                    @dateProps.push prop

                when 'UPDATED_AT'
                    @updatedAt = prop
                    @dateProps.push prop

                when 'MODEL'
                    @modelProps.push prop
                    @modelDic[prop] = true

                    if facade.getModel(typeInfo.model).isEntity
                        @entityProps.push prop
                        @entityDic[prop] = true
                    else
                        @nonEntityProps.push prop

                when 'MODEL_LIST'
                    @listProps.push prop

        return

    ###*
    check if the given prop is entity prop

    @method isEntityProp
    @param {String} prop
    @return {Boolean}
    ###
    isEntityProp: (prop) ->
        return @entityDic[prop]?

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

    @method isModelProp
    @param {String} prop
    @return {Boolean}
    ###
    isModelProp: (prop) ->
        return @modelDic[prop]?

module.exports = PropInfo
