# base-domain

simple module to help build Domain-Driven Design"

[latest API documentation Page](http://cureapp.github.io/base-domain/doc/v0.3.4/index.html)

![concept](https://github.com/CureApp/base-domain/blob/master/base-domain-classes.png "base-domain-classes")

## installation

```bash
$ npm install -g base-domain
```


## usage

### generate base file

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
        doctors      : @TYPES.MODELS 'doctor'

module.exports = Hospital
```

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


hospitalRepository.find(where: name: 'CureApp Hp.').then (hospitals)->
    console.log hospitals

```

## API documentations
- [v0.3.4](http://cureapp.github.io/base-domain/doc/v0.3.4/index.html)
- [v0.3.3](http://cureapp.github.io/base-domain/doc/v0.3.3/index.html)



