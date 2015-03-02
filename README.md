# base-domain

simple module to help build Domain-Driven Design"

![concept](https://github.com/CureApp/base-domain/blob/master/base-domain-classes.png "base-domain-classes")

## installation

```bash
$ npm install base-domain
```


## usage

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

hospitalRepository.find(where: name: 'CureApp Hp.').then (hospitals)->
    console.log hospitals
```

