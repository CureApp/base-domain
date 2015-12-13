'use strict'

Includer = require './includer'

###*
include submodels

@class EntityCollectionIncluder
@extends Includer
@module base-domain
###
class EntityCollectionIncluder extends Includer

    constructor: ->
        super
        { @itemModelName } = @ModelClass

    include: ->

        Promise.all([
            @includeItems()
            super
        ])


    includeItems: ->

        return if @model.loaded()

        items = []
        for id in @model.ids
            item = @entityPool.get(@itemModelName, id)
            items.push item if item?

        if items.length is @model.length
            @model.setItems(items)
            return

        repo = @root.createPreferredRepository(@itemModelName)
        return if not repo?

        if repo.constructor.isSync
            items = repo.getByIds(@model.ids, include: @options)

            if items.length isnt @model.ids.length
                console.warn('EntityCollectionIncluder#include(): some ids were not loaded.')

            @model.setItems(items)

        else
            return unless @options.async

            return repo.getByIds(@model.ids, include: @options).then (items) =>

                if items.length isnt @model.ids.length
                    console.warn('EntityCollectionIncluder#include(): some ids were not loaded.')

                @model.setItems(items)

            .catch (e) ->


module.exports = EntityCollectionIncluder
