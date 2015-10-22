
AggregateRoot = require './aggregate-root'
BaseSyncRepository = require './base-sync-repository'

###*
repository of local memory, saved in AggregateRoot

@class LocalRepository
@extends BaseSyncRepository
@module base-domain
###
class LocalRepository extends BaseSyncRepository

    ###*
    root name
    ###
    @aggregateRoot: null

    constructor: ->

        super

        if not @constructor.aggregateRoot?
            throw @error 'aggregateRootIsRequired', """
                #{@constructor.getName()} must define its static property '@aggregateRoot'.
            """
        Root = @root.getModel @constructor.aggregateRoot

        if (Root::) not instanceof AggregateRoot
            throw @error 'invalidAggregateRoot', """
                #{@constructor.getName()} has invalid aggregateRoot property.
                '#{@constructor.aggregateRoot}' is not instance of AggregateRoot.
            """

        if @root not instanceof Root
            throw @error 'invalidRoot', """
                '#{@constructor.getName()}' wasn't created by AggregateRoot '#{@constructor.aggregateRoot}'.

                Try

                aggregateRoot.createRepository('#{@constructor.modelName}')

                where aggregateRoot is an instance of '#{@constructor.aggregateRoot}'.
            """

        @client = @root.useMemoryResource(@constructor.modelName)

module.exports = LocalRepository
