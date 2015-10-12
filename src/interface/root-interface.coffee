
###*
interface of Aggregate Root

@class RootInterface
@module base-domain
###
class RootInterface

   # this file is just a concept and no implementation here.

    ###*
    key: modelName, value: MemoryResource

    @property {Object(MemoryResource)} memories
    ###

    ###*
    create a factory instance

    @method createFactory
    @param {String} modelName
    @return {BaseFactory}
    ###

    ###*
    create a repository instance

    @method createRepository
    @param {String} modelName
    @return {BaseRepository}
    ###

    ###*
    get a model class

    @method getModel
    @param {String} modelName
    @return {Function}
    ###
    ###*
    create an instance of the given modelName using obj

    @method createModel
    @param {String} modelName
    @param {Object} obj
    @param {Object} [options]
    @return {BaseModel}
    ###

    ###*
    get or create a memory resource to save to @memories

    @method useMemoryResource
    @param {String} modelName
    @return {MemoryResource}
    ###

module.exports = RootInterface
