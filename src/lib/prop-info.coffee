
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
        properties whose type is MODEL and the model extends Entity
        @property entityProps
        @type Array
        ###
        @entityProps = []

        ###*
        key value pairs of (property => TypeInfo)
        @property dic
        @type Object
        ###
        @dic = {}


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

                when 'CREATED_AT'
                    @createdAt = prop

                when 'UPDATED_AT'
                    @updatedAt = prop

                when 'MODEL', 'MODELS'
                    @modelProps.push prop
                    if facade.getModel(typeInfo.model).isEntity
                        @entityProps.push prop


module.exports = PropInfo
