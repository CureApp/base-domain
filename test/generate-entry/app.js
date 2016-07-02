const { VendingMachineFacade, Drink, FundamentalsPrice } = require('./src/entry')
const domain = VendingMachineFacade.createInstance()

const repo = domain.createRepository('drink')
const coke = repo.get('coke')

console.assert(coke instanceof Drink)
console.assert(coke.price instanceof FundamentalsPrice)
console.log(coke.id)
