


class BaseFacade


    ###*
    get a model class

    @method getModel
    @param {String} name
    @return {Class}
    ###
    getModel: (name)->
        return @require(name)


    ###*
    get a factory class

    @method getFactory
    @param {String} name
    @return {Class}
    ###
    getFactory: (name)->
        return @require("#{name}-factory")


    ###*
    get a repository class

    @method getRepository
    @param {String} name
    @return {Class}
    ###
    getRepository: (name)->
        return @require("#{name}-repository")


    ###*
    create a factory instance

    @method createFactory
    @param {String} name
    @return {DomainFactory}
    ###
    createFactory: (name)->
        @create("#{name}-factory")


    ###*
    create a repository instance

    @method createRepository
    @param {String} name
    @return {DomainRepository}
    ###
    createRepository: (name)->
        @create("#{name}-repository")


    ###*
    read a file and returns class

    domain下のファイルは、DomainFacadeクラスのインスタンスを引数にし、
    クラスを戻り値とした関数をexportしている

    @method require
    @param {String} name
    @return {Class}
    ###
    require: (name)->

        if @classes[name] is true

            @logger.error("循環参照を検出 domain/#{name}")
            throw new Error("循環参照を検出 domain/#{name}")


        unless @classes[name]?

            @classes[name] = true

            classGenerator = require("#{@dirname}/domain/#{name}")
            @classes[name] = classGenerator(@)

        return @classes[name]


    ###*
    domain下のファイルを読み込み、クラスのインスタンスを返す

    @method create
    @param {String} name
    @param {Object} params コンストラクタの第一引数に渡す値
    @return {DomainFactory}
    ###
    create: (name, params)->
        DomainClass = @require(name)
        return new DomainClass(params)


    ###*
    utilファイルを読み込み、クラスを返す

    util下のファイルは、DomainFacadeクラスのインスタンスを引数にし、
    クラスを戻り値とした関数をexportしている

    @method getUtil
    @param {String} name
    @param {Class} BaseClass 基底となるクラス. あれば.
    @return {Class}
    ###
    getUtil: (name, BaseClass)->

        if @utils[name] is true

            @logger.error("循環参照を検出 util/#{name}")
            throw new Error("循環参照を検出 util/#{name}")

        unless @utils[name]?

            @utils[name] = true
            classGenerator = require("#{@dirname}/util/#{name}")
            @utils[name] = classGenerator(@, BaseClass)

        return @utils[name]



    ###*
    utilファイルを読み込み、クラスのインスタンスを返す

    @method createUtil
    @param {String} name
    @param {Object} params コンストラクタの第一引数に渡す値
    @return {Class}
    ###
    createUtil: (name, params)->
        UtilClass = @getUtil(name)
        return new UtilClass(params)


    ###*
    # constディレクトリ下のファイルを読み込み、その値を返す.
    #
    # 一度読み込んでいる場合はキャッシュから返す.
    #
    @method getConst
    @return {Object}
    #
    ###
    getConst: (name)->
        @const[name] ?= require("#{@dirname}/const/#{name}")


    ###*
    DomainErrorクラスのオブジェクトを


    @method error
    @param {String} reason エラーの理由
    @param {String} message optional
    @return {DomainError}
    ###
    error: (reason, message)->

        DomainError = @require('domain-error')
        return new DomainError(reason, message)


    ###*
    ACSPromiseの response errorかどうか判定

    @method isACSResponseError
    @param {Error} e
    @return {Boolean}
    ###
    isACSResponseError: (e)->
        return e?.isACSResponseError is true


    ###*
    DomainErrorかどうか判定する

    @method isDomainError
    @param {Error} e
    @return {Boolean}
    ###
    isDomainError: (e)->

        DomainError = @require('domain-error')
        return e instanceof DomainError



