
class PropInfo

    constructor: (props) ->

        @createdAt = null
        @updatedAt = null
        @modelProps = []
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


module.exports = PropInfo
