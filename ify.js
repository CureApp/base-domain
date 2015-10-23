/*
 * transformer for browserify
 * preloads all the domain files in the directory you set
 *
 * usage
 *
 * browserify -t [ base-domain/ify --dirname /path/to/domain/dir ]
 */

var BaseDomainify = require('./dist/base-domainify');
var baseDomainify = new BaseDomainify()

module.exports = function(file, options) {
    return baseDomainify.run(file, options);
};

module.exports.BaseDomainify = BaseDomainify;
