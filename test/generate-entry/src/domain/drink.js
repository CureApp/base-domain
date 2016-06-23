const { Entity } = require('base-domain')
const { TYPES } = Entity

class Drink extends Entity {
}

Drink.properties = {
    name: TYPES.STRING,
    price: TYPES.MODEL('fundamentals/price')
}

module.exports = Drink
