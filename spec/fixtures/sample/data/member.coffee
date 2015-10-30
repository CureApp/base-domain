
module.exports =

    dependencies: [
        'hobby'
    ]

    data: (pool) ->

        shinout:
            firstName    : 'Shin'
            age          : 29
            registeredAt : '2013-03-10'
            hobbies      : [
                pool.hobby.keyboard
                pool.hobby.ingress
            ]
            newHobbies   : [
                pool.hobby.jogging
            ]

        satake:
            firstName    : 'Kohta'
            age          : 32
            registeredAt : '2012-02-20'
            hobbies      : [
                pool.hobby.sailing
            ]
