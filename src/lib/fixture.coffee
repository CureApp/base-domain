
fs = require('fs')

Promise = require('es6-promise').Promise


###*

@class Fixture
###
class Fixture


    ###*
    @constructor
    @param {Object} [options]
    @param {String} [options.dirname='./fixtures'] directory to have fixture files. /data, /tsvs should be included in the directory.
    @param {Object} [options.data={}] default data, merged to dataPool
    @param {String} [options.debug] if true, shows debug log
    ###
    constructor: (@facade, options = {}) ->

        @debug  = options.debug ? !!@facade.debug

        # loading model files
        @fxModelMap = {}

        @dirname = options.dirname ? __dirname + '/fixtures'

        files = fs.readdirSync(@dirname + '/data')

        for file in files
            modelName = file.split('.').shift()
            setting = require(@dirname + '/data/' + file)

            @fxModelMap[modelName] = new FixtureModel(@, modelName, setting)


        # initial data pool
        @dataPool =
            if options.data? and typeof options.data is 'object'
                JSON.parse JSON.stringify options.data
            else
                {}

        @dataPool[modelName] ?= {} for modelName of @fxModelMap


    ###*
    add data to pool for model's data

    @method addToDataPool
    @return {Object}
    ###
    addToDataPool: (modelName, dataName, data) ->

        @dataPool[modelName][dataName] = data


    ###*
    inserts data in LoopBack

    @param {Array} names list of fixture models to insert data
    @method insert
    @return {Promise}
    ###
    insert: (names)->

        names ?= (name for name of @fxModelMap)

        names = [names] if typeof names is 'string'

        modelNames = @resolveDependencies(names)

        if not modelNames.length
            console.log 'no data to insert.' if @debug
            return Promise.resolve(true)


        console.log('insertion order') if @debug
        console.log("\t#{modelNames.join(' -> ')}\n") if @debug


        do insert = =>

            modelName = modelNames.shift()

            if not modelName?
                return Promise.resolve(true)

            fxModel = @fxModelMap[modelName]

            fxModel.insert().then ->
                insert()

            .catch (e) =>
                console.error e.stack

                return false


    ###*
    adds dependent models, topological sort

    @private
    @param {Array} names list of fixture models to insert data
    @method resolveDependencies
    @return {Array} model names
    ###
    resolveDependencies: (names) ->

        # adds dependent models 
        namesWithDependencies = []

        for el in names
            do add = (name = el) =>

                return if name in namesWithDependencies

                namesWithDependencies.push name

                fxModel = @fxModelMap[name]

                unless fxModel
                    throw new Error("model '#{name}' is not found. It might be written in some 'dependencies' property.")

                add(depname) for depname in fxModel.dependencies


        # topological sort
        visited = {}
        sortedNames = []

        for el in namesWithDependencies

            do visit = (name = el, ancestors = []) =>

                fxModel = @fxModelMap[name]

                return if visited[name]?

                ancestors.push(name)

                visited[name] = true

                for depname in fxModel.dependencies

                    if depname in ancestors
                        throw new Error('dependency chain is making loop')


                    visit(depname, ancestors.slice())

                sortedNames.push(name)

        return sortedNames




###*

@class FixtureModel
###
class FixtureModel

    ###*
    @constructor
    ###
    constructor: (@fx, @name, setting = {}) ->

        @dependencies = setting.dependencies ? []
        @data = setting.data ? ->



    ###*
    inserts data in LoopBack

    @method insert
    @return {Promise}
    ###
    insert: ->

        modelDataMap =
            switch typeof @data
                when 'string'
                    @readTSV(@data)
                when 'function'
                    @data(@fx.dataPool)


        dataNames = Object.keys modelDataMap

        console.log("inserting #{dataNames.length} data into #{@name}") if @fx.debug

        factory = @fx.facade.createFactory(@name)
        repository = @fx.facade.createRepository(@name, debug: false)

        do insert = =>

            if dataNames.length is 0
                return Promise.resolve(true)

            dataName = dataNames.shift()
            data = modelDataMap[dataName]



            model = factory.createFromObject data

            repository.save(model).then (savedModel) =>

                @fx.addToDataPool(@name, dataName, savedModel)
                insert()



    ###*
    read TSV, returns model data

    @method readTSV
    ###
    readTSV: (filename) ->


        objs = {}

        lines = fs.readFileSync(@fx.dirname + '/tsvs/' + filename, 'utf8').split('\n')

        tsv = (line.split('\t') for line in lines)

        names = tsv.shift() # first line is title
        names.shift() # first column is dataName

        for data in tsv
            obj = {}
            dataName = data.shift()

            break if not dataName # dataNameが空文字列となっている行よりも下の行はみない

            for name, i in names
                break if not name # titleが空文字列となっているカラムより右のカラムは見ない
                value = data[i]
                value = Number(value) if value.match(/^[0-9]+$/) # 数字だけのカラムは数値として扱う
                obj[name] = value

            objs[dataName] = obj

        return objs





module.exports = Fixture
