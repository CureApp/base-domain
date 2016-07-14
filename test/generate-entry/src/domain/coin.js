const { Entity } = require('base-domain')
const { TYPES } = Entity

class Coin extends Entity {
}

Coin.properties = {
    type: TYPES.STRING,
}

module.exports = Coin
