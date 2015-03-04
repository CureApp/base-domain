
facade = require './init'

Hobby  = facade.getModel 'hobby'
Hobby2 = require './domain/hobby'

describe 'Entity', ->

    it 'has methods', ->


        hobby = new Hobby()
        hobby2 = new Hobby2()
        hobby.name = 'alto sax'

        expect(hobby.getName()).to.equal 'alto sax'


