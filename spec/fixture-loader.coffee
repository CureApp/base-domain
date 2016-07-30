
Facade = require './base-domain'
{ FixtureLoader } = require './others'



describe 'FixtureLoader', ->

    before ->

        @createTSV = (rows...) -> (row.join('\t') for row in rows).join('\n')
        @facade = require('./create-facade').create()
        @fxLoader = new FixtureLoader(@facade, ['dummy'])


    describe 'readTSVContent', ->

        it 'parses tsv', ->

            txt = @createTSV(
                ['id', 'name', 'age', 'gender']
                ['tanaka', 'tanaka', '23', 'f']
                ['nakata', 'nakata', '34', 'm']
            )

            result = @fxLoader.readTSVContent(txt)

            assert.deepEqual(result, {
                tanaka: { id: 'tanaka', name: 'tanaka', age: 23, gender: 'f' }
                nakata: { id: 'nakata', name: 'nakata', age: 34, gender: 'm' }
            })


        it 'parses a tsv string containing line break in cell', ->

            txt = @createTSV(
                ['id', 'name', 'hobby']
                ['tanaka', 'tanaka', '"runnning\nreading books"']
                ['nakata', 'nakata', '"drawing\nsewing"']
            )

            result = @fxLoader.readTSVContent(txt)

            assert.deepEqual(result, {
                tanaka: { id: 'tanaka', name: 'tanaka', hobby: "runnning\nreading books" }
                nakata: { id: 'nakata', name: 'nakata', hobby: "drawing\nsewing" }
            })


        it 'returns object without columns located at the rightside of a empty field name', ->

            txt = @createTSV(
                ['id', 'name', 'age', '', 'gender']
                ['tanaka', 'tanaka', '23', 'tokyo', 'f']
                ['nakata', 'nakata', '34', 'osaka', 'm']
            )

            result = @fxLoader.readTSVContent(txt)

            assert.deepEqual(result, {
                tanaka: { id: 'tanaka', name: 'tanaka', age: 23, }
                nakata: { id: 'nakata', name: 'nakata', age: 34, }
            })


        it 'returns empty object when the first column is empty', ->

            txt = @createTSV(
                ['', 'name', 'age']
                ['', 'tanaka', '23']
                ['', 'nakata', '34']
            )

            result = @fxLoader.readTSVContent(txt)

            assert.deepEqual(result, {})


        it 'returns object without rows located at the below of a empty row', ->

            txt = @createTSV(
                ['id', 'name', 'age']
                ['tanaka', 'tanaka', '23']
                []
                ['nakata', 'nakata', '34']
            )

            result = @fxLoader.readTSVContent(txt)

            assert.deepEqual(result, {
                tanaka: { id: 'tanaka', name: 'tanaka', age: 23, }
            })
