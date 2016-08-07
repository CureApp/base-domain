'use strict';
var DomainError, Fixture, FixtureLoader, debug;

DomainError = require('./lib/domain-error');

FixtureLoader = require('./fixture-loader');

debug = null;


/**
load data from directory and generates fixtures
only available in Node.js

@class Fixture
@module base-domain
 */

Fixture = (function() {

  /**
  @constructor
  @param {Object} [options]
  @param {String|Array} [options.dirname='./fixtures'] director(y|ies) to have fixture files. /data, /tsvs should be included in the directory.
  @param {String} [options.debug] if true, shows debug log
   */
  function Fixture(facade, options) {
    var debugMode, ref;
    this.facade = facade;
    if (options == null) {
      options = {};
    }
    debugMode = (ref = options.debug) != null ? ref : !!this.facade.debug;
    if (debugMode) {
      require('debug').enable('base-domain:fixture');
    }
    debug = require('debug')('base-domain:fixture');
    this.dirnames = options.dirname != null ? Array.isArray(options.dirname) ? options.dirname : [options.dirname] : [__dirname + '/fixtures'];
  }


  /**
  inserts data to datasource
  
  @method insert
  @param {Array} names list of fixture models to insert data
  @public
  @return {Promise(EntityPool)}
   */

  Fixture.prototype.insert = function(names) {
    return new FixtureLoader(this.facade, this.dirnames).load({
      async: true,
      names: names
    });
  };

  return Fixture;

})();

module.exports = Fixture;
