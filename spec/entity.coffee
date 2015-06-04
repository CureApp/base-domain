
facade = require './init'

Hobby  = facade.getModel 'hobby'

describe 'Entity', ->

    it 'has isEntity, true', ->

        expect(Hobby).to.have.property 'isEntity', true

