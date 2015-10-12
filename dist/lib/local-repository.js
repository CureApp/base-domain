var BaseSyncRepository, LocalRepository,
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

BaseSyncRepository = require('./base-sync-repository');

LocalRepository = (function(superClass) {
  extend(LocalRepository, superClass);

  function LocalRepository() {
    LocalRepository.__super__.constructor.apply(this, arguments);
    this.client = this.root.useMemoryResource(this.constructor.modelName);
  }

  return LocalRepository;

})(BaseSyncRepository);

module.exports = LocalRepository;
