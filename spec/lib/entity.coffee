
facade = require('../create-facade').create('domain')

Hobby  = facade.getModel 'hobby'

describe 'Entity', ->

    it 'has isEntity, true', ->

        expect(Hobby).to.have.property 'isEntity', true

