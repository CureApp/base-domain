

facade = null

###*
parent class of model, factory and repository.

gives them @getFacade() method.

@class Base
@module base-domain
###
class Base

    getFacade : -> facade ?= require('./facade').getInstance()


module.exports = Base
