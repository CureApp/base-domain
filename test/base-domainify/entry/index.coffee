domain = require('../domain-selector')

iPhone6S = domain.createRepository('device').get('iphone6s')

url = domain.getModule('web').createModel('url', value: 'localhost:4157')

count = domain.createRepository('cli/device').count()

fsExist = 'fs exists'

try
    fs = domain.constructor.fs
    fs.existsSync('./index.js')
catch e
    fsExist = 'fs is not found'


console.log("device name is #{iPhone6S.name}, count is #{count}, url.value is localhost:4157 and #{fsExist}")
