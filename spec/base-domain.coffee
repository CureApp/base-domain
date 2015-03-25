
basedomain = if process.env.DIST is '1' then '..' else '../src/lib/facade'

console.log "base-domain path: #{basedomain}"

module.exports = require(basedomain)
