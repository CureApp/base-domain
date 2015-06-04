
class PropInfo

    constructor: (props, facade) ->

        @createdAt = null
        @updatedAt = null
        @modelProps  = []
        @entityProps = []
        @props = {}
        @list = []


        for prop, typeInfo of props

            @props[prop] = typeInfo
            @list.push prop

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
