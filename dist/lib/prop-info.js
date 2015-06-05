
/**
parses model properties and classifies them

@class PropInfo
@module base-domain
 */
var PropInfo;

PropInfo = (function() {
  function PropInfo(props, facade) {

    /**
    property whose type is CREATED_AT
    @property createdAt
    @type String
     */
    this.createdAt = null;

    /**
    property whose type is UPDATED_AT
    @property updatedAt
    @type String
     */
    this.updatedAt = null;

    /**
    properties whose type is MODEL
    @property modelProps
    @type Array
     */
    this.modelProps = [];

    /**
    properties whose type is MODEL_LIST
    @property listProps
    @type Array
     */
    this.listProps = [];

    /**
    properties whose type is MODEL and the model extends Entity
    @property entityProps
    @type Array
     */
    this.entityProps = [];

    /**
    key value pairs of (property => TypeInfo)
    @property dic
    @type Object
     */
    this.dic = {};
    this.entityDic = {};
    this.modelDic = {};
    this.build(props, facade);
  }


  /**
  classify each prop by type
  
  @method build
  @private
   */

  PropInfo.prototype.build = function(props, facade) {
    var prop, typeInfo;
    for (prop in props) {
      typeInfo = props[prop];
      this.dic[prop] = typeInfo;
      switch (typeInfo.name) {
        case 'CREATED_AT':
          this.createdAt = prop;
          break;
        case 'UPDATED_AT':
          this.updatedAt = prop;
          break;
        case 'MODEL':
          this.modelProps.push(prop);
          this.modelDic[prop] = true;
          if (facade.getModel(typeInfo.model).isEntity) {
            this.entityProps.push(prop);
            this.entityDic[prop] = true;
          }
          break;
        case 'MODEL_LIST':
          this.listProps.push(prop);
      }
    }
  };


  /**
  check if the given prop is entity prop
  
  @method isEntityProp
  @param {String} prop
  @return {Boolean}
   */

  PropInfo.prototype.isEntityProp = function(prop) {
    return this.entityDic[prop] != null;
  };


  /**
  check if the given prop is model prop
  
  @method isModelProp
  @param {String} prop
  @return {Boolean}
   */

  PropInfo.prototype.isModelProp = function(prop) {
    return this.modelDic[prop] != null;
  };

  return PropInfo;

})();

module.exports = PropInfo;
