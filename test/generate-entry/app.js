const { VendingMachineFacade, Drink, FundamentalsPrice } = require('./src/entry')
const domain = VendingMachineFacade.createInstance()
console.assert(domain.nonExistingClassNames['drink-factory'])
console.assert(domain.nonExistingClassNames['coin-factory'] === undefined)
console.assert(domain.nonExistingClassNames['fundamentals/price'] === undefined)

const repo = domain.createRepository('drink')
const coke = repo.get('coke')

console.assert(coke instanceof Drink)
console.assert(coke.price instanceof FundamentalsPrice)
console.log(coke.id)
