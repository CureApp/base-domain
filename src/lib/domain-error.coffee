


###*
error thrown by base-domain module

@class DoctorRegistrationService
@extends Error
@module base-domain

# class DomainError extends Error  # not worked.
# see http://stackoverflow.com/questions/19422145/property-in-subclass-of-error-not-set
###

DomainError = (reason, message)->

    if message instanceof Error
        self = message

    else if typeof message is 'object'

        self = new Error message.message ? reason
        self[k] = v for k, v of message

    else
        message ?= reason
        self = new Error message

    self.name      = 'DomainError'
    self.__proto__ = DomainError.prototype

    ###*
    reason of the error
    alphanumeric string (without space) is recommended,

    @property reason
    @type {String}

    @reason
    ###
    self.reason = reason


    return self


DomainError.prototype.__proto__= Error.prototype

module.exports = DomainError
