
###*
interface of Aggregate Root

@class RootInterface
@module base-domain
###
class RootInterface

   # this file is just a concept and no implementation here.

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
    create an instance of the given modelName using obj

    @method createModel
    @param {String} modelName
    @param {Object} obj
    @param {Object} [options]
    @return {BaseModel}
    ###

module.exports = RootInterface
