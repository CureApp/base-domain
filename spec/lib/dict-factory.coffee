
facade = require('../create-facade').create()
Facade = facade.constructor
{ Ids, DictFactory, MemoryResource } = Facade


describe 'DictFactory', ->

    before ->

        class Hobby extends Facade.Entity
            @properties:
                name: @TYPES.STRING

        class NonEntity extends Facade.BaseModel
            @properties:
                name: @TYPES.STRING

        class HobbyRepository extends Facade.BaseSyncRepository
            @modelName: 'hobby'
            client: new MemoryResource()

        class HobbyDict extends Facade.BaseDict
            @properties:
                ne: @TYPES.MODEL 'non-entity'
                st: @TYPES.STRING

            @itemModelName: 'hobby'
            @key: (item) -> item.name

        class NonEntityDict extends Facade.BaseDict
            @properties:
                ne: @TYPES.MODEL 'non-entity'
                st: @TYPES.STRING

            @itemModelName: 'non-entity'
            @key: (item) -> item.name


        facade.addClass('hobby', Hobby)
        facade.addClass('non-entity', NonEntity)
        facade.addClass('hobby-dict', HobbyDict)
        facade.addClass('hobby-repository', HobbyRepository)
        facade.addClass('non-entity-dict', NonEntityDict)

        @hobbyFactory = facade.createFactory('hobby', true)
        @neFactory = facade.createFactory('non-entity', true)

        facade.createRepository('hobby').save(id: 'abc', name: 'camping')


    describe 'createEmpty', ->

        before ->
            hobbyDictFactory = DictFactory.create('hobby-dict', @hobbyFactory)

            @hobbyDict = hobbyDictFactory.createEmpty()

        it 'creates dict', ->

            expect(@hobbyDict).to.be.instanceof Facade.BaseDict
            expect(@hobbyDict.items).to.be.an 'object'
            expect(@hobbyDict.loaded).to.be.true

        it 'creates empty dict', ->
            expect(@hobbyDict.items).to.eql {}
            expect(@hobbyDict.ids).to.have.length 0


    describe 'createFromObject', ->

        it 'regards arg as object when arg has items', ->

            obj = items:
                keyboard    : name : 'keyboard'
                programming : name : 'programming'

            hobbyDictFactory = DictFactory.create('hobby-dict', @hobbyFactory)
            dict = hobbyDictFactory.createFromObject(obj)
            expect(dict.items).to.have.property 'keyboard'
            expect(dict.items).to.have.property 'programming'


        it 'regards arg as dict object when arg has ids', (done) ->

            obj = ids: ['abc']

            hobbyDictFactory = DictFactory.create('hobby-dict', @hobbyFactory)
            dict = hobbyDictFactory.createFromObject(obj)

            dict.on 'loaded', ->
                expect(Object.keys dict.items).to.have.length 1
                done()


        it 'attaches properties', ->
            obj =
                ne:
                    name: 'non-entity-prop'
                str: 'awesome hobbies'
                items:
                    keyboard    : name : 'keyboard'
                    programming : name : 'programming'

            hobbyDictFactory = DictFactory.create('hobby-dict', @hobbyFactory)
            dict = hobbyDictFactory.createFromObject(obj)
            expect(dict).to.have.property 'ne'
            expect(dict.ne).to.be.instanceof facade.getModel('non-entity')
            expect(dict.ne).to.have.property 'name', 'non-entity-prop'
            expect(dict.str).to.equal 'awesome hobbies'
            expect(dict.items).to.have.property 'programming'
            expect(dict.items).to.have.property 'keyboard'



        it 'restores original object from plain object', ->

            obj =
                ne:
                    name: 'non-entity-prop'
                str: 'awesome hobbies'
                items:
                    keyboard    : name : 'keyboard'
                    programming : name : 'programming'

            neDictFactory = DictFactory.create('non-entity-dict', @neFactory)

            dict = neDictFactory.createFromObject(obj)
            dict2 = neDictFactory.createFromObject dict.toPlainObject()

            expect(dict).to.deep.equal dict2




    describe 'createFromArray', ->

        it 'regards string array as id dic', (done) ->
            hobbyDictFactory = DictFactory.create('hobby-dict', @hobbyFactory)
            dict = hobbyDictFactory.createFromArray(['abc'])

            dict.on 'loaded', ->
                expect(Object.keys dict.items).to.have.length 1
                done()

        it 'regards object array as pre-model dict', (done) ->

            data = [ {id: 3, name: 'keyboard'}, {id: 2, name: 'sailing'} ]

            hobbyDictFactory = DictFactory.create('hobby-dict', @hobbyFactory)
            dict = hobbyDictFactory.createFromArray(data)

            dict.on 'loaded', ->
                Hobby = facade.getModel 'hobby'
                expect(Object.keys dict.items).to.have.length 2
                expect(dict.items.keyboard).to.be.instanceof Hobby
                expect(dict.items.sailing).to.be.instanceof Hobby
                expect(dict.ids).to.eql new Ids [3,2]
                done()

