[![Stories in Progress](https://badge.waffle.io/CureApp/base-domain.png?label=In%20Progress&title=In Progress)](https://waffle.io/CureApp/base-domain)
# base-domain

framework for Domain-Driven Design in JavaScript (or CoffeeScript, recommended.)

[latest API documentation Page](http://cureapp.github.io/base-domain/doc/index.html)


## installation

```bash
$ npm install -g base-domain
```


## concept
base-domain helps easier practice of Domain-Driven Design.

1. list models in the domain of your concern (by your own way)
1. define models with base-domain
1. define their factories with base-domain
1. define their repositories with base-domain
1. define services with base-domain if needed

### essential classes and relations
- Base
- Facade
- BaseModel
- BaseFactory
- BaseRepository
- Entity
- ValueObject
- BaseList
- BaseDict

![class relations](https://github.com/CureApp/base-domain/blob/master/base-domain-classes.png "base-domain-classes")

#### Base
[API Doc](http://cureapp.github.io/base-domain/doc/classes/Base.html)
- Base is an origin of all classes
- Base has Facade
- Base does not have any other properties or methods

#### Facade
[API Doc](http://cureapp.github.io/base-domain/doc/classes/Facade.html)
- Facade is the gate of all classes
- Facade knows all classes
- Facade is module-exported in base-domain: require('base-domain') returns Facade class

#### BaseModel
[API Doc](http://cureapp.github.io/base-domain/doc/classes/BaseModel.html)
- BaseModel is a base class of model
- essential methods for model are defined
- BaseModel is a child of Base

#### BaseFactory
[API Doc](http://cureapp.github.io/base-domain/doc/classes/BaseFactory.html)
- BaseFactory is a base class of factory
- BaseFactory creates specific BaseModel instance
- BaseFactory is a child of Base

#### BaseRepository
[API Doc](http://cureapp.github.io/base-domain/doc/classes/BaseRepository.html)
- BaseRepository is a base class of repository
- BaseRepository connects to database, filesystem or other external data resources (settings needed).
- BaseRepository saves specific BaseModel to data resources
- BaseRepository read BaseModels from data resources
- BaseRepository base BaseFactory (to generate BaseModel from data resources)


#### ValueObject
[API Doc](http://cureapp.github.io/base-domain/doc/classes/ValueObject.html)
- ValueObject is child of BaseModel
- instance of ValueObject does not have id
- ValueObject.isEntity is false
- that's all of ValueObject

#### Entity
[API Doc](http://cureapp.github.io/base-domain/doc/classes/Entity.html)
- Entity is child of BaseModel
- instance of Entity has id
- Entity.isEntity is true


#### BaseList
[API Doc](http://cureapp.github.io/base-domain/doc/classes/BaseList.html)
- BaseList is child of ValueObject
- BaseList has many BaseModels as items
- BaseList#items is array of specific BaseModel

#### BaseDict
[API Doc](http://cureapp.github.io/base-domain/doc/classes/BaseDict.html)
- BaseDict is child of ValueObject
- BaseDict has many BaseModels as items
- BaseDict#items is dictionary of key => specific BaseModel
- BaseDict.key is function to get key from item


## usage

### generate base files

```bash
MODEL_NAME='foo-bar'
DIR_NAME='.'
$ base-domain $MODEL_NAME $DIR_NAME
```
- ./foo-bar.coffee
- ./foo-bar-factory.coffee
- ./foo-bar-repository.coffee

are generated.

- foo-bar.coffee defines and exports class FooBar extends Entity
- foo-bar-factory.coffee defines and exports class FooBarFactory extends BaseFactory
- foo-bar-repository.coffee defines and exports class FooBarRepository extends BaseRepository


### model definition
model is classified into "Entity" and "ValueObject"

Entity is model with id, ValueObject is model without id.

```coffee
# {domain-dir}/hospital.coffee
class Hospital extends require('base-domain').Entity

    # property types
    @properties:
        name         : @TYPES.STRING
        address      : @TYPES.STRING
        beds         : @TYPES.NUMBER
        registeredAt : @TYPES.DATE
        isValidated  : @TYPES.BOOLEAN
        doctors      : @TYPES.MODEL_LIST 'doctor'
        flags        : @TYPES.MODEL_DICT 'flag'
        doctorIdx    : @TYPES.TMP 'NUMBER'

module.exports = Hospital
```
#### properties definition

there are two kinds of @TYPES.XXX

1. @TYPES.XXX is object
2. @TYPES.XXX is function

when @TYPES.XXX is object, you can just set props as follows

```coffee
    @properties:
        somePropName: @TYPES.XXX
```

mark | property type     | meaning
-----|-------------------|-----------------------------------------------------------------
 x   | @TYPES.ANY        | prop accepts any type
 x   | @TYPES.STRING     | prop is string
 x   | @TYPES.NUMBER     | prop is number
 x   | @TYPES.DATE       | prop is date
 x   | @TYPES.BOOLEAN    | prop is boolean
 x   | @TYPES.ARRAY      | prop is array
 x   | @TYPES.OBJECT     | prop is object
 x   | @TYPES.BUFFER     | prop is buffer
 x   | @TYPES.GEOPOINT   | prop is geopoint
 o   | @TYPES.CREATED_AT | prop is date, automatically inserted when first saved
 o   | @TYPES.UPDATED_AT | prop is date, automatically inserted each time saved
 o   | @TYPES.TMP        | prop is not saved

these are object-typed types. Currently, types with marked "x" are just provides the name of the type.
base-domain `does not validate` the prop's type.


when @TYPES.XXX is function, you must set type with arguments like
```coffee
    @properties:
        somePropName: @TYPES.XXX 'arg1', 'arg2'
```

 property type     | meaning           |  arg1           | arg2
-------------------|-------------------|-----------------|-----------------------------------
 @TYPES.MODEL      | prop is BaseModel | model name      | id prop name (if model is Entity)
 @TYPES.MODEL_LIST | prop is BaseList  | item model name | model name (model name of BaseList)
 @TYPES.MODEL_DICT | prop is BaseDict  | item model name | model name (model name of BaseDict)
 @TYPES.TMP        | prop is not saved | type            |




### factory definition
```coffee
# {domain-dir}/hospital-factory.coffee
class HospitalFactory extends require('base-domain').BaseFactory

    @modelName: 'hospital'

module.exports = HospitalFactory
```

### repository definition
```coffee
# {domain-dir}/hospital-repository.coffee
class HospitalRepository extends require('base-domain').BaseRepository

    @modelName: 'hospital'

module.exports = HospitalRepository
```


### use them by facade

```coffee
domain = require('base-domain').createInstance
    dirname: '/path/to/domain-dir'


Hospital = domain.getModel('hospital')
hospitalFactory = domain.createFactory('hospital')
hospitalRepository = domain.createRepository('hospital')

hosp = hospitalFactory.createFromObject(name: 'Suzuki Clinic')


hospitalRepository.query(where: name: 'CureApp Hp.').then (hospitals)->
    console.log hospitals

```

### baselist definition

```coffee
# {domain-dir}/hospital-list.coffee
class HospitalList extends require('base-domain').BaseList

    @itemModelName: 'hospital'

module.exports = HospitalList
```

### basedict definition

```coffee
# {domain-dir}/hospital-dict.coffee
class HospitalDict extends require('base-domain').BaseDict

    @itemModelName: 'hospital'
    @key: (item) -> item.id

module.exports = HospitalDict
```


# use in browser with browserify
[browserify](http://browserify.org/) is a tool for packing a js project into one file for web browsers

to enable base-domain's requiring system in browsers, use 'base-domain/ify' transformer.

```bash
browserify -t [ base-domain/ify --dirname /path/to/domain/dir ] <entry-file>

