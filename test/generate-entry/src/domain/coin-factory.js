const { BaseFactory } = require('base-domain')

class CoinFactory extends BaseFactory {
    createFiveYen() {
        return this.createFromObject({ type: 'FIVE', value: 5 })
    }
}

CoinFactory.modelName = 'coin'

module.exports = CoinFactory
