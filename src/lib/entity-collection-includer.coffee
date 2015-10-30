
Includer = require './includer'

###*
include submodels

@class EntityCollectionIncluder
@extends Includer
@module base-domain
###
class EntityCollectionIncluder extends Includer

    include: ->

        Promise.all([
            @includeItems()
            super
        ])


    includeItems: ->

        if @model.loaded()
            return

        repo = @createRepository(@ModelClass.itemModelName)

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
