const { ValueObject } = require('base-domain')
const { TYPES } = ValueObject

class Price extends ValueObject {
}

Price.properties = {
    value: TYPES.NUMBER
}

module.exports = Price
