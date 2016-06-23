const domain = require('./src/entry').createInstance()

const repo = domain.createRepository('drink')
const coke = repo.get('coke')
console.log(coke.id)
