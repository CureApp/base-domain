
facade = require('./facade').createInstance()

iPhone6S = facade.createRepository('device').get('iphone6s')
console.assert(iPhone6S.name is 'iPhone6S')
console.assert(iPhone6S.os is 'iOS')
console.log('uglify-js test succeeded!')
