
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
    properties whose type is DATE, CREATED_AT and UPDATED_AT
    @property dateProps
    @type Array
     */
    this.dateProps = [];

    /**
    properties whose type is MODEL and the model does not extend Entity
    @property nonEntityProps
    @type Array
     */
    this.nonEntityProps = [];

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
        case 'DATE':
          this.dateProps.push(prop);
          break;
        case 'CREATED_AT':
          this.createdAt = prop;
          this.dateProps.push(prop);
          break;
        case 'UPDATED_AT':
          this.updatedAt = prop;
          this.dateProps.push(prop);
          break;
        case 'MODEL':
          this.modelProps.push(prop);
          this.modelDic[prop] = true;
          if (facade.getModel(typeInfo.model).isEntity) {
            this.entityProps.push(prop);
            this.entityDic[prop] = true;
          } else {
            this.nonEntityProps.push(prop);
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
  get typeInfo by prop
  
  @method getTypeInfo
  @param {String} prop
  @return {TypeInfo}
   */

  PropInfo.prototype.getTypeInfo = function(prop) {
    return this.dic[prop];
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
