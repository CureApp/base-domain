
class PropInfo

    constructor: (props, facade) ->

        @createdAt = null
        @updatedAt = null
        @modelProps  = []
        @entityProps = []
        @dic = {}

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
