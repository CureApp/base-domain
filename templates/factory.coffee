###
generated by base-domain generator
###


BaseFactory = require('base-domain').BaseFactory


class <%=@Model %>Factory extends BaseFactory

    @modelName: '<%= @model %>'

module.exports = <%=@Model %>Factory
