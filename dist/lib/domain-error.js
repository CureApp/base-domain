
/**
error thrown by base-domain module

    class DomainError extends Error  # not worked.

see http://stackoverflow.com/questions/19422145/property-in-subclass-of-error-not-set


@class DomainError
@extends Error
@module base-domain
 */
var DomainError;

DomainError = function(reason, message) {
  var k, ref, self, v;
  if (message instanceof Error) {
    self = message;
  } else if (typeof message === 'object') {
    self = new Error((ref = message.message) != null ? ref : reason);
    for (k in message) {
      v = message[k];
      self[k] = v;
    }
  } else {
    if (message == null) {
      message = reason;
    }
    self = new Error(message);
  }
  self.name = 'DomainError';
  self.__proto__ = DomainError.prototype;

  /**
  reason of the error
  alphanumeric string (without space) is recommended,
  
  @property reason
  @type {String}
  
  @reason
   */
  self.reason = reason;
  return self;
};

DomainError.prototype.__proto__ = Error.prototype;

module.exports = DomainError;
