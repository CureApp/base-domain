'use strict'
fs      = require 'fs'
Path    = require 'path'
coffee  = require 'coffee-script'
require('coffee-script/register')

Path.isAbsolute ?= (str) -> str.charAt(0) is '/'

Facade = require './main'
{Base} = Facade

MasterDataResource = require './master-data-resource'

class DomainPacker

    pack: (dirname) ->
        absDirname = @absolutePath(dirname)
        @validate(absDirname)
        console.log @getJSCode(absDirname)


    validate: (dirname) ->
        throw new Error("dirname: '#{dirname}' is not found.") if not fs.existsSync(dirname)


    getJSCode: (dirname) ->
        propCodes = []
        propCodes.push @getMasterProp(dirname)
        propCodes.push @getCoreProp(dirname)
        propCodes.push @getModulesProp(dirname)
        return "module.exports = {\n#{propCodes.join(',\n')}\n}"


    getMasterProp: (dirname) ->
        if masterJSONPath = @getMasterJSONPath(dirname)
            return "  masterData: require('#{masterJSONPath}')"
        else
            return "  masterData: {}"


    getCoreProp: (dirname) ->

        coreCodes = for filename in @getClassFiles(dirname)
            name = filename.split('.')[0]
            path = @relativePath(dirname) + '/' + name
            "    '#{name}': require('#{path}')"

        return "  core: {\n#{coreCodes.join(',\n')}\n  }"


    getModulesProp: (dirname) ->

        modulesCode = for moduleName in @getModuleNames(dirname)
            modulePath = Path.join(dirname, moduleName)
            moduleCodes = for filename in @getClassFiles(modulePath)
                name = filename.split('.')[0]
                path = @relativePath(modulePath) + '/' + name
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
    getMasterJSONPath: (dirname) ->

        try
            facade = Facade.createInstance(dirname: @absolutePath(dirname), master: true)

            { masterJSONPath } = facade.master

            return '' if not fs.existsSync(masterJSONPath)

            relPath = MasterDataResource.getJSONPath(@relativePath(dirname))
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


    relativePath: (path) ->
        # dir = Path.dirname(@file)
        dir = process.cwd()
        relPath = Path.relative(dir, path)

        if relPath.charAt(0) isnt '.'
            relPath = './' + relPath

        return relPath


    absolutePath: (path) ->
        return path if Path.isAbsolute path
        return process.cwd() + '/' + path


module.exports = DomainPacker

new DomainPacker().pack(process.argv[2])
