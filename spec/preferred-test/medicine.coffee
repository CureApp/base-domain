
{ Entity } = require('../base-domain')

class Medicine extends Entity

    @properties:
        name: @TYPES.STRING
        tradeName: @TYPES.STRING
        genericName: @TYPES.STRING


module.exports = Medicine
