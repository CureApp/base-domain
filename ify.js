/*
 * transformer for browserify
 * preloads all the domain files in the directory you set
 *
 * usage
 *
 * browserify -t [ base-domain/ify --dirname /path/to/domain/dir ]
 */

require('coffee-script/register');
var BaseDomainify = require('./src/base-domainify.coffee');
var baseDomainify = new BaseDomainify()

module.exports = function(file, options) {
    return baseDomainify.run(file, options);
};
