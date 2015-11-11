[![Circle CI](https://circleci.com/gh/CureApp/base-domain.svg?style=svg)](https://circleci.com/gh/CureApp/base-domain)

[![Stories in Progress](https://badge.waffle.io/CureApp/base-domain.png?label=In%20Progress&title=In Progress)](https://waffle.io/CureApp/base-domain)
# base-domain

framework for Domain-Driven Design in JavaScript (or CoffeeScript, recommended.)

[latest API documentation Page](http://cureapp.github.io/base-domain/index.html)


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
- BaseService
- Entity
- AggregateRoot
- ValueObject
- BaseList
- BaseDict

![class relations](https://github.com/CureApp/base-domain/blob/master/classes.png "base-domain-classes")

#### Base
[API Doc](http://cureapp.github.io/base-domain/classes/Base.html)
- Base is an origin of all classes
- Base has Facade
- Base does not have any other properties or methods

#### Facade
[API Doc](http://cureapp.github.io/base-domain/classes/Facade.html)
- Facade is the gate of all classes
- Facade knows all classes
- Facade is module-exported in base-domain: require('base-domain') returns Facade class

#### BaseModel
[API Doc](http://cureapp.github.io/base-domain/classes/BaseModel.html)
- BaseModel is a base class of model
- essential methods for model are defined
- BaseModel is a child of Base

#### BaseFactory
[API Doc](http://cureapp.github.io/base-domain/classes/BaseFactory.html)
- BaseFactory is a base class of factory
- BaseFactory creates specific BaseModel instance
- BaseFactory is a child of Base

#### BaseRepository
[API Doc](http://cureapp.github.io/base-domain/classes/BaseRepository.html)
- BaseRepository is a base class of repository
- BaseRepository connects to database, filesystem or other external data resources (settings needed).
- BaseRepository saves specific BaseModel to data resources
- BaseRepository read BaseModels from data resources
- BaseRepository has BaseFactory (to generate BaseModel from data resources)


#### ValueObject
[API Doc](http://cureapp.github.io/base-domain/classes/ValueObject.html)
- ValueObject is child of BaseModel
- instance of ValueObject does not have id
- ValueObject.isEntity is false
- that's all of ValueObject

#### Entity
[API Doc](http://cureapp.github.io/base-domain/classes/Entity.html)
- Entity is child of BaseModel
- instance of Entity has id
- Entity.isEntity is true

#### AggregateRoot
[API Doc](http://cureapp.github.io/base-domain/classes/AggregateRoot.html)
- AggregateRoot is child of Entity
- AggregateRoot implements RootInterface, thus it can create other models, factories and repositories.

#### BaseList
[API Doc](http://cureapp.github.io/base-domain/classes/BaseList.html)
- BaseList is child of ValueObject
- BaseList has many BaseModels as items
- BaseList#items is array of specific BaseModel

#### BaseDict
[API Doc](http://cureapp.github.io/base-domain/classes/BaseDict.html)
- BaseDict is child of ValueObject
- BaseDict has many BaseModels as items
- BaseDict#items is dictionary of key => specific BaseModel
- BaseDict.key is function to get key from item


## usage

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
        doctors      : @TYPES.MODEL 'doctor-list'
        flags        : @TYPES.MODEL 'flag-dict'

module.exports = Hospital
```
#### properties definition

@TYPES.XXX is an object and also a function.

```coffee
    @properties:
        aaa: @TYPES.STRING
        bbb: @TYPES.NUMBER 3
        ccc: @TYPES.MODEL 'foo-bar'
```

mark | property type     | meaning                      |  arg1           | arg2
-----|-------------------|------------------------------|-----------------|-----------------------------------
 x   | @TYPES.ANY        | prop accepts any type        | default value   |
 x   | @TYPES.STRING     | prop is string               | default value   |
 x   | @TYPES.NUMBER     | prop is number               | default value   |
 x   | @TYPES.DATE       | prop is date                 | default value   |
 x   | @TYPES.BOOLEAN    | prop is boolean              | default value   |
 x   | @TYPES.ARRAY      | prop is array                | default value   |
 x   | @TYPES.OBJECT     | prop is object               | default value   |
 x   | @TYPES.BUFFER     | prop is buffer               | default value   |
 x   | @TYPES.GEOPOINT   | prop is geopoint             | default value   |
 o   | @TYPES.CREATED_AT | date set when first saved    | default value   |
 o   | @TYPES.UPDATED_AT | date set each time saved     | default value   |
 o   | @TYPES.MODEL      | prop is BaseModel            | model name      | id prop name (if model is Entity)

Types with marked "x" just provide the name of the type.
base-domain **does not validate** the prop's type.



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

### list definition

```coffee
# {domain-dir}/hospital-list.coffee
class HospitalList extends require('base-domain').BaseList

    @itemModelName: 'hospital'

module.exports = HospitalList
```

### dict definition

```coffee
# {domain-dir}/hospital-dict.coffee
class HospitalDict extends require('base-domain').BaseDict

    @itemModelName: 'hospital'
    @key: (item) -> item.id

module.exports = HospitalDict
```


# use in browser with browserify
[browserify](http://browserify.org/) is a tool for packing a js project into one file for web browsers

To enable base-domain's requiring system in browsers, use 'base-domain/ify' transformer.

```bash
browserify -t [ base-domain/ify --dirname /path/to/domain/dir ] <entry-file>
```

