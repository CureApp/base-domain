
{ AggregateRoot } = require('../base-domain')

class Hospital extends AggregateRoot

    @properties:
        name: @TYPES.STRING


module.exports = Hospital
