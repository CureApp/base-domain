domain = require('../domain-selector')
iPhone6S = domain.createRepository('device').get('iphone6s')
console.log("device name is #{iPhone6S.name} and os is #{iPhone6S.os}")
