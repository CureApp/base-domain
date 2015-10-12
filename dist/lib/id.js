
/**
id

@class Id
@module base-domain
 */
var Id;

Id = (function() {
  function Id(val) {
    this.val = val.toString();
  }

  Id.prototype.toString = function() {
    return this.val.toString();
  };

  Id.prototype.toPlainObject = function() {
    return this.toString();
  };

  Id.prototype.equals = function(id) {
    if (id == null) {
      return false;
    }
    return id.toString() === this.toString();
  };

  return Id;

})();

module.exports = Id;
