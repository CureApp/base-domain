
{ BaseSyncRepository, MemoryResource }  = require('../base-domain')

###*
repository of member

@class MemberRepository
@extends BaseSyncRepository
###
class MemberRepository extends BaseSyncRepository

    ###*
    model name to create

    @property modelName
    @static
    @protected
    @type String
    ###
    @modelName: 'member'

    client: new MemoryResource()

module.exports = MemberRepository
