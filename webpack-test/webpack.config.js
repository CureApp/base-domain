// eslint-disable-next-line
const webpack = require('webpack')
module.exports = {
    context: __dirname,
    entry: {
        js: ['./index.js']
    },
    output: {
        path: `${__dirname}/dist`,
        filename: 'bundle.js'
    }
}
