
facade = require './init'

Hobby  = facade.getModel 'hobby'

describe 'Entity', ->

    it 'has methods', ->


        hobby = new Hobby()
        hobby.name = 'alto sax'

        expect(hobby.getName()).to.equal 'alto sax'



    it 'is available from loading file by require', ->
        Hobby2 = require './domain/hobby'

        hobby2 = new Hobby2()
        hobby2.name = 'alto sax'
        expect(hobby2.getName()).to.equal 'alto sax'
