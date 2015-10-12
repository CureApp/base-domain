
facade = require('../create-facade').create()

Facade = facade.constructor

{ AggregateRoot, Entity, BaseDict, LocalRepository } = facade.constructor


describe 'AggregateRoot', ->

    class Game extends AggregateRoot
        @properties:
            cards   : @TYPES.MODEL_DICT 'card'
            players : @TYPES.MODEL_DICT 'player'


    class Card extends Entity
        @properties:
            name: @TYPES.STRING

    class CardDict extends BaseDict
        @itemModelName: 'card'

    class CardRepository extends LocalRepository
        @modelName: 'card'

    class Player extends Entity
        @properties:
            name: @TYPES.STRING

    class PlayerDict extends BaseDict
        @itemModelName: 'player'

    class PlayerRepository extends LocalRepository
        @modelName: 'player'


    facade.addClass('game', Game)
    facade.addClass('card', Card)
    facade.addClass('card-dict', CardDict)
    facade.addClass('card-repository', CardRepository)
    facade.addClass('player', Player)
    facade.addClass('player-dict', PlayerDict)
    facade.addClass('player-repository', PlayerRepository)

    describe 'createModel', ->

        it 'set root to descendants', ->

            game = facade.createModel('game')
            card = game.createModel('card', name: 'road1')

            expect(card.root).to.equal game
            expect(game.root).to.equal game



    describe 'createRepository', ->

        it 'saves to @memories', ->

            game = facade.createModel('game')
            card = game.createModel('card', name: 'road1')

            game.createRepository('card').save card

            expect(Object.keys game.memories).to.have.length 1


    describe 'toPlainObject', ->

        it 'saves to @memories', ->

            game = facade.createModel('game')
            card = game.createModel('card', name: 'road1')

            game.createRepository('card').save card

            expect(Object.keys game.memories).to.have.length 1

            plain = game.toPlainObject()

            expect(plain).to.eql
                cards:   ids: []
                players: ids: []
                memories:
                    card:
                        pool: '1': name: 'road1', id: '1'
                        currentIdNum: 1

