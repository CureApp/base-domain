// Generated by CoffeeScript 1.10.0
(function() {
  var DrinkRepository, MasterRepository,
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  MasterRepository = require('base-domain').MasterRepository;

  DrinkRepository = (function(superClass) {
    extend(DrinkRepository, superClass);

    function DrinkRepository() {
      return DrinkRepository.__super__.constructor.apply(this, arguments);
    }

    DrinkRepository.modelName = 'drink';

    return DrinkRepository;

  })(MasterRepository);

  module.exports = DrinkRepository;

}).call(this);