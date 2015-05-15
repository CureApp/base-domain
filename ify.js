/*
 * transformer for browserify
 * preloads all the domain files in the directory you set
 *
 * usage
 *
 * browserify -t [ base-domain/ify --dirname /path/to/domain/dir ]
 */

require('coffee-script/register');
module.exports = require('./src/base-domainify.coffee');
