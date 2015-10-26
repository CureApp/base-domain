
Logger = require '../logger'

{ Entity } = require 'base-domain'

class Device extends Entity
    @properties:
        name: @TYPES.STRING
        os  : @TYPES.STRING

module.exports = Device
