
facade = require './init'

Diary  = facade.getModel 'diary'
Member = facade.getModel 'member'
Hobby  = facade.getModel 'hobby'
memberFactory = facade.createFactory('member')
diaryFactory = facade.createFactory('diary')
hobbyFactory = facade.createFactory('hobby')

member = memberFactory.createFromObject
    id: 12
    firstName: 'Shin'
    age: 29
    registeredAt: new Date()
    hobbies: [
        { id: 1, name: 'keyboard' }
        { id: 2, name: 'ingress' }
        { id: 3, name: 'Shogi' }
    ]



describe 'BaseModel', ->

    describe '@getPropertyInfo', ->

        it 'returns map of type info', ->
            info = Diary.getPropertyInfo()

            expect(info.title.name).to.equal 'STRING'
            expect(info.comment.name).to.equal 'STRING'
            expect(info.author.name).to.equal 'MODEL'
            expect(info.author.model).to.equal 'member'
            expect(info.date.name).to.equal 'DATE'
            expect(info.upd.name).to.equal 'UPDATED_AT'
            expect(info.upd.name).to.equal 'UPDATED_AT'

        it 'returns info of prop when argument given', ->
            typeInfo = Diary.getPropertyInfo('author')
            expect(typeInfo.name).to.equal 'MODEL'
            expect(typeInfo.model).to.equal 'member'


        it 'returns undefined when invalid prop is given', ->
            typeInfo = Diary.getPropertyInfo('xxxx')
            expect(typeInfo).not.to.exist


    describe '@getPropOfCreatedAt', ->
        it 'returns prop name of createdAt', ->
            expect(Member.getPropOfCreatedAt()).to.equal 'mCreatedAt'

        it 'returns null when no prop name of createdAt', ->
            expect(Hobby.getPropOfCreatedAt()).not.to.exist


    describe '@getPropOfUpdatedAt', ->
        it 'returns prop name of updatedAt', ->
            expect(Member.getPropOfUpdatedAt()).to.equal 'mUpdatedAt'


        it 'returns prop name of updatedAt', ->
            expect(Hobby.getPropOfUpdatedAt()).not.to.exist


    describe '@camelize', ->
        it 'shinout-no-macbook-pro => shinoutNoMacbookPro', ->
            expect(Hobby.camelize('shinout-no-macbook-pro')).to.equal 'shinoutNoMacbookPro'


    describe 'isSubClassOfEntity', ->
        it 'returns true to descendant of Entity', ->
            hobby = new Hobby()
            expect(hobby.isSubClassOfEntity('hobby')).to.be.true


        xit 'returns false to descendant of BaseModel', ->
            hobby = new Hobby()
            expect(hobby.isSubClassOfEntity('xxxxx')).to.be.false



    describe 'toPlainObject', ->

        it 'returns plain object without relational models (has many)', ->
            plainMember = member.toPlainObject()

            expect(plainMember.registeredAt).to.be.instanceof Date
            expect(plainMember.id).to.equal 12
            expect(plainMember.firstName).to.equal 'Shin'
            expect(plainMember.age).to.equal 29
            expect(plainMember.hobbies).not.to.exist
            expect(plainMember.hobbyIds).to.eql [1,2,3]

        it 'returns plain object without relational models (has one / belongs to)', ->
            diary = diaryFactory.createFromObject
                title : 'crazy about room335'
                comment: 'progression of room335 is wonderful'
                author: member
                date  : new Date()

            plainDiary = diary.toPlainObject()

            expect(plainDiary.title).to.equal diary.title
            expect(plainDiary.comment).to.equal diary.comment
            expect(plainDiary.date).to.eql diary.date
            expect(plainDiary.author).not.to.exist
            expect(plainDiary.authorId).not.to.exist
            expect(plainDiary.memberId).to.equal 12


    describe 'updateRelationIds', ->
        it 'adds relation ids (has one / belongs to)', ->
            diary = diaryFactory.createFromObject
                title : 'crazy about room335'
                comment: 'progression of room335 is wonderful'
                author: member
                date  : new Date()

            delete diary.memberId

            expect(diary.memberId).not.to.exist
            diary.updateRelationIds()

            expect(diary.memberId).to.equal 12


        it 'adds relation ids (has many)', ->
            delete member.hobbyIds

            expect(member.hobbyIds).not.to.exist
            member.updateRelationIds()

            expect(member.hobbyIds).to.eql [1,2,3]


    describe 'setRelatedModel(s)', ->
        it 'set relation and its ids (has one / belongs to)', ->
            diary = diaryFactory.createFromObject
                title : 'crazy about room335'
                comment: 'progression of room335 is wonderful'
                date  : new Date()

            diary.setRelatedModel('author', member)

            expect(diary.author).to.equal member
            expect(diary.memberId).to.equal 12

        it 'set relation and its ids (has many)', ->
            mem = memberFactory.createEmptyModel()
            mem.setRelatedModels 'hobbies', member.hobbies

            expect(mem.hobbies).to.equal member.hobbies
            expect(mem.hobbyIds).to.eql [1,2,3]



    describe 'unsetRelatedModel(s)', ->
        it 'unset relation and its ids (has one / belongs to)', ->
            diary = diaryFactory.createFromObject
                title : 'crazy about room335'
                comment: 'progression of room335 is wonderful'
                date  : new Date()
                author : member

            diary.unsetRelatedModel('author')

            expect(diary.author).not.to.exist
            expect(diary.memberId).not.to.exist

        it 'unset relation and its ids (has many)', ->
            mem = memberFactory.createEmptyModel()
            mem.setRelatedModels 'hobbies', member.hobbies

            mem.unsetRelatedModels 'hobbies'
            expect(mem.hobbies).not.to.exist
            expect(mem.hobbyIds).to.eql []


    describe 'addRelatedModels', ->
        it 'add submodels and its ids (has many)', ->
            mem = memberFactory.createEmptyModel()
            mem.setRelatedModels 'hobbies', member.hobbies

            newHobby1 = hobbyFactory.createFromObject { id: 4, name: 'sailing' }
            newHobby2 = hobbyFactory.createFromObject { id: 5, name: 'shopping' }

            mem.addRelatedModels 'hobbies', newHobby1, newHobby2
            expect(mem.hobbies[3]).to.equal newHobby1
            expect(mem.hobbies[4]).to.equal newHobby2
            expect(mem.hobbyIds).to.eql [1,2,3,4,5]

