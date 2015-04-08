
module.exports =

    dependencies: [
        'hobby'
    ]

    data: (fixtureData) ->

        shinout:
            firstName    : 'Shin'
            age          : 29
            registeredAt : '2013-03-10'
            hobbies      : [
                fixtureData.hobby.keyboard
                fixtureData.hobby.ingress
            ]
            newHobbies   : [
                fixtureData.hobby.jogging
            ]

        satake:
            firstName    : 'Kohta'
            age          : 32
            registeredAt : '2012-02-20'
            hobbies      : [
                fixtureData.hobby.sailing
            ]
