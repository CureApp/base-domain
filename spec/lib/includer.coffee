
Facade = require '../base-domain'

{ ValueObject, Entity, BaseAsyncRepository, BaseSyncRepository } = Facade

{ MemoryResource, Includer } = require '../others'


describe 'Includer', ->

    before (done) ->

        @facade = require('../create-facade').create()

        class A extends ValueObject
            @properties:
                b: @TYPES.MODEL 'b'
                c: @TYPES.MODEL 'c'

        class B extends Entity
            @properties:
                c: @TYPES.MODEL 'c'
                name: @TYPES.STRING

        class BRepository extends BaseAsyncRepository
            client: new MemoryResource()

        class CRepository extends BaseSyncRepository
            client: new MemoryResource()

        class C extends Entity
            @properties:
                name: @TYPES.STRING

        @facade.addClass('a', A)
        @facade.addClass('b', B)
        @facade.addClass('c', C)
        @facade.addClass('b-repository', BRepository)
        @facade.addClass('c-repository', CRepository)

        bRepo = @facade.createRepository('b')
        cRepo = @facade.createRepository('c')

        cRepo.save(id: 'xxx', name: 'shin')
        cRepo.save(id: 'yyy', name: 'satake')

        Promise.all([
            bRepo.save(id: 'xxx', name: 'shin', cId: 'xxx')
            bRepo.save(id: 'yyy', name: 'satake', cId: 'yyy')
        ]).then -> done()


    beforeEach ->

        @a = @facade.createModel('a', { bId: 'xxx', cId: 'xxx' }, include: null)


    describe 'include', ->

        it 'includes subEntities', (done) ->

            class Main extends ValueObject
                @properties:
                    name: @TYPES.STRING
                    sub: @TYPES.MODEL 'sub-item', 'subId'

            class SubItem extends Entity
                @properties:
                    name: @TYPES.STRING

            class SubItemRepository extends BaseAsyncRepository
                @modelName: 'sub-item'
                get: (id) ->
                    item = @getFacade().createModel('sub-item', {id: id, name: 'mock'})
                    return Promise.resolve item


            f = require('../create-facade').create()
            f.addClass('main', Main)
            f.addClass('sub-item', SubItem)
            f.addClass('sub-item-repository', SubItemRepository)

            main = f.createModel 'main',
                name: 'xxx'
                subId: 'abc'

            main.include().then =>
                expect(main.sub).to.be.instanceof f.getModel 'sub-item'
                done()

            .catch done


    describe 'createRepository', ->

        it 'checks parent class\'s repository', ->

            class Parent extends Entity
                @properties:
                    name: @TYPES.STRING

            class Child extends Parent
                @properties:
                    name: @TYPES.STRING

            class ParentRepository extends BaseSyncRepository
                @modelName: 'parent'

            f = require('../create-facade').create()
            f.addClass('parent', Parent)
            f.addClass('child', Child)
            f.addClass('parent-repository', ParentRepository)

            pnt = f.createModel 'parent'
            repo = new Includer(pnt).createRepository('child')

            expect(repo).to.be.instanceof ParentRepository
