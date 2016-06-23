'use strict'
fs      = require 'fs'
Path    = require 'path'

Path.isAbsolute ?= (str) -> str.charAt(0) is '/'

Facade = require './main'
{Base} = Facade

MasterDataResource = require './master-data-resource'

class NonNodeFacadeGenerator

    generate: (facadePath, dirname, outfile) ->
        absFacadePath = @absolutePath(facadePath)
        absDirname = @absolutePath(dirname)
        outfilePath = @absolutePath(outfile)

        @validate(facadePath, absDirname, outfilePath)

        cwd = Path.dirname(outfilePath)

        code = @getPackedDataCode(absDirname, cwd) + '\n'
        code += """
        const Facade = require('#{@relativePath(absFacadePath, cwd)}')
        Facade.prototype.init = function() { return this.initWithPacked(packedData) }
        module.exports = Facade
        """

        fs.writeFileSync(outfilePath, code)


    validate: (absFacadePath, absDirname, outfilePath) ->
        throw new Error("'#{absFacadePath}' is not found.") if not fs.existsSync(absFacadePath)
        throw new Error("dirname: '#{absDirname}' is not found.") if not fs.existsSync(absDirname)

        outDir = Path.dirname(outfilePath)
        throw new Error("output directory: '#{outDir}' is not found.") if not fs.existsSync(outDir)


    getPackedDataCode: (dirname, cwd) ->
        propCodes = []
        propCodes.push @getMasterProp(dirname, cwd)
        propCodes.push @getCoreProp(dirname, cwd)
        propCodes.push @getModulesProp(dirname, cwd)
        return "const packedData = {\n#{propCodes.join(',\n')}\n}"


    getMasterProp: (dirname) ->
        if masterJSONPath = @getMasterJSONPath(dirname)
            return "  masterData: require('#{masterJSONPath}')"
        else
            return "  masterData: {}"


    getCoreProp: (dirname, cwd) ->

        coreCodes = for filename in @getClassFiles(dirname)
            name = filename.split('.')[0]
            path = @relativePath(dirname, cwd) + '/' + name
            "    '#{name}': require('#{path}')"

        return "  core: {\n#{coreCodes.join(',\n')}\n  }"


    getModulesProp: (dirname, cwd) ->

        modulesCode = for moduleName in @getModuleNames(dirname)
            modulePath = Path.join(dirname, moduleName)
            moduleCodes = for filename in @getClassFiles(modulePath)
                name = filename.split('.')[0]
                path = @relativePath(modulePath, cwd) + '/' + name
                "      #{name}': require('#{path}')"

            "    #{moduleName}: {\n#{moduleCodes.join(',\n')}\n    }"

        return "  modules: {\n#{modulesCode.join(',\n')}\n  }"


    getModuleNames: (dirname) ->

        path = @absolutePath(dirname)

        fs.readdirSync(path)
            .filter (subDirName) -> subDirName isnt 'master-data'
            .filter (subDirName) -> subDirName isnt 'custom-roles'
            .map (subDirname) -> Path.join dirname, subDirname
            .filter (subDirPath) -> fs.statSync(subDirPath).isDirectory()
            .filter (subDirPath) ->
                fs.readdirSync(subDirPath).some (filename) ->
                    klass = require Path.join(subDirPath, filename)
                    (klass::) instanceof Base
            .map (subDirPath) -> Path.basename(subDirPath)


    ###*
    @method getCodeOfMasterData
    @private
    @return {String} path
    ###
    getMasterJSONPath: (dirname, cwd) ->

        try
            facade = Facade.createInstance(dirname: @absolutePath(dirname), master: true)

            { masterJSONPath } = facade.master

            return '' if not fs.existsSync(masterJSONPath)

            relPath = MasterDataResource.getJSONPath(@relativePath(dirname, cwd))
            return relPath

        catch e
            return ''


    ###*
    get domain files to load

    @method getClassFiles
    @private
    @return {Array} filenames
    ###
    getClassFiles: (dirname) ->

        fileInfoDict = {}

        path = @absolutePath(dirname)

        for filename in fs.readdirSync(path)

            [ name, ext ] = filename.split('.')
            continue if ext not in ['js', 'coffee']

            klass = require path + '/' + filename

            fileInfoDict[name] = filename: filename, klass: klass

        files = []
        for name, fileInfo of fileInfoDict

            { klass, filename } = fileInfo
            continue if filename in files

            ParentClass = Object.getPrototypeOf(klass::).constructor

            if ParentClass.className and pntFileName = fileInfoDict[ParentClass.getName()]?.filename

                files.push pntFileName unless pntFileName in files

            files.push filename

        return files


    relativePath: (path, cwd) ->
        # dir = Path.dirname(@file)
        relPath = Path.relative(cwd, path)

        if relPath.charAt(0) isnt '.'
            relPath = './' + relPath

        return relPath


    absolutePath: (path) ->
        return path if Path.isAbsolute path
        return process.cwd() + '/' + path


module.exports = NonNodeFacadeGenerator
