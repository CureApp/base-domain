
facade = require('../create-facade').create()
Facade = facade.constructor
DicFactory = Facade.DicFactory

describe 'DicFactory', ->

    before ->

        class Hobby extends Facade.Entity
            @properties:
                name: @TYPES.STRING

        class NonEntity extends Facade.BaseModel
            @properties:
                name: @TYPES.STRING

        class HobbyRepository extends Facade.MasterRepository
            @modelName: 'hobby'

        class HobbyDic extends Facade.BaseDic
            @properties:
                ne: @TYPES.MODEL 'non-entity'
                st: @TYPES.STRING

            @itemModelName: 'hobby'
            @key: (item) -> item.name

        facade.addClass('hobby', Hobby)
        facade.addClass('non-entity', NonEntity)
        facade.addClass('hobby-dic', HobbyDic)
        facade.addClass('hobby-repository', HobbyRepository)

        @hobbyFactory = facade.createFactory('hobby', true)


    describe 'createEmpty', ->

        before ->
            hobbyDicFactory = DicFactory.create('hobby-dic', @hobbyFactory)

            @hobbyDic = hobbyDicFactory.createEmpty()

        it 'creates dic', ->

            expect(@hobbyDic).to.be.instanceof Facade.BaseDic
            expect(@hobbyDic.items).to.be.an 'object'
            expect(@hobbyDic.loaded).to.be.true

        it 'creates empty dic', ->
            expect(@hobbyDic.items).to.eql {}
            expect(@hobbyDic.ids).to.have.length 0


    describe 'createFromObject', ->

        it 'regards arg as object when arg has items', ->

            obj = items:
                keyboard    : name : 'keyboard'
                programming : name : 'programming'

            hobbyDicFactory = DicFactory.create('hobby-dic', @hobbyFactory)
            dic = hobbyDicFactory.createFromObject(obj)
            expect(dic.items).to.have.property 'keyboard'
            expect(dic.items).to.have.property 'programming'


        it 'regards arg as dic object when arg has ids', (done) ->

            obj = ids: ['dummy']

            hobbyDicFactory = DicFactory.create('hobby-dic', @hobbyFactory)
            dic = hobbyDicFactory.createFromObject(obj)

            dic.on 'loaded', ->
                expect(Object.keys dic.items).to.have.length.above 0
                done()


        it 'attaches properties', ->
            obj =
                ne:
                    name: 'non-entity-prop'
                str: 'awesome hobbies'
                items:
                    keyboard    : name : 'keyboard'
                    programming : name : 'programming'

            hobbyDicFactory = DicFactory.create('hobby-dic', @hobbyFactory)
            dic = hobbyDicFactory.createFromObject(obj)
            expect(dic).to.have.property 'ne'
            expect(dic.ne).to.be.instanceof facade.getModel('non-entity')
            expect(dic.ne).to.have.property 'name', 'non-entity-prop'
            expect(dic.str).to.equal 'awesome hobbies'
            expect(dic.items).to.have.property 'programming'
            expect(dic.items).to.have.property 'keyboard'



    describe 'createFromArray', ->

        it 'regards string array as id dic', (done) ->
            hobbyDicFactory = DicFactory.create('hobby-dic', @hobbyFactory)
            dic = hobbyDicFactory.createFromArray(['dummy'])

            dic.on 'loaded', ->
                expect(Object.keys dic.items).to.have.length.above 0
                done()

        it 'regards object array as pre-model dic', (done) ->

            data = [ {id: 3, name: 'keyboard'}, {id: 2, name: 'sailing'} ]

            hobbyDicFactory = DicFactory.create('hobby-dic', @hobbyFactory)
            dic = hobbyDicFactory.createFromArray(data)

            dic.on 'loaded', ->
                Hobby = facade.getModel 'hobby'
                expect(Object.keys dic.items).to.have.length 2
                expect(dic.items.keyboard).to.be.instanceof Hobby
                expect(dic.items.sailing).to.be.instanceof Hobby
                expect(dic.ids).to.eql [3,2]
                done()

