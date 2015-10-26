
# switch source path by environment variable `DIST`
module.exports = if process.env.DIST is '1' then '../dist' else '../src'

console.log 'source dir:', require('path').basename module.exports
