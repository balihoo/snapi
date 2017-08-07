assert = require 'assert'
sinon = require 'sinon'
mockery = require 'mockery'

Logger = undefined
mockBunyan = sinon.spy()
fakeErr = new Error "loud noises!"

describe 'logger unit tests', ->
  before ->
    mockery.enable useCleanCache: true
    mockery.warnOnUnregistered false
    mockery.registerAllowable '../src/logger'
    mockery.registerMock 'bunyan', mockBunyan
    Logger = require '../src/logger'

  describe 'constructor', ->
    context 'when a logger is supplied', ->
      it 'uses the supplied logger', ->
        Logger = require '../src/logger'

        customLogger =
          error: ->
          info: ->
          fatal: ->

        logger = new Logger
          log:
            logger: customLogger

        assert.strictEqual logger.log, customLogger
        assert.ok not mockBunyan.called

    context 'when no log options are supplied', ->
      it 'creates a bunyan instance with default options', ->
        Logger = require '../src/logger'

        logger = new Logger {}
        assert.ok mockBunyan.calledOnce
        assert.ok mockBunyan.calledWith
          name: 'snapi'
          streams: [
            path: './snapi.log'
            type: 'rotating-file'
            level: 'warn'
            period: '1d'
            count: 10
          ]

  describe 'unhandledRejection()', ->
    it 'calls log.error', ->
      Logger = require '../src/logger'

      customLogger =
        error: ->
        info: ->
        fatal: ->

      mockLogger = sinon.mock customLogger
      mockLogger.expects('error').once().withArgs(
        unhandledRejection: true
        err: fakeErr,
        fakeErr.message
      )

      logger = new Logger
        log:
          logger: customLogger

      handler = logger.unhandledRejection()
      handler fakeErr
      mockLogger.verify()

  describe 'unhandledProcessException()', ->
    it 'calls log.fatal', ->
      Logger = require '../src/logger'

      customLogger =
        error: ->
        info: ->
        fatal: ->

      mockLogger = sinon.mock customLogger
      mockLogger.expects('fatal').once().withArgs(
        unhandledProcessException: true
        err: fakeErr,
        fakeErr.message
      )

      logger = new Logger
        log:
          logger: customLogger

      handler = logger.unhandledProcessException()
      handler fakeErr
      mockLogger.verify()

  describe 'unhandledRestifyException()', ->
    it 'calls log.error and sends an internal server error', ->
      res = send: ->
      mockRes = sinon.mock res
      mockRes.expects('send').once().withArgs 500, 'Internal server error'

      fakeReq = some: 'request'
      fakeRoute = some: 'route'

      Logger = require '../src/logger'

      customLogger =
        error: ->
        info: ->
        fatal: ->

      mockLogger = sinon.mock customLogger
      mockLogger.expects('error').once().withArgs(
        req: fakeReq
        res: res
        route: fakeRoute
        unhandledRestifyException: true
        err: fakeErr,
        fakeErr.message
      )

      logger = new Logger
        log:
          logger: customLogger

      handler = logger.unhandledRestifyException()
      handler fakeReq, res, fakeRoute, fakeErr
      mockLogger.verify()
      mockRes.verify()

  describe 'errorToJson()', ->
    it 'includes custom error properties', ->
      err = new Error("Some error")
      err.customProp = "Something else"
      result = err.toJSON()
      assert.ok result.customProp

  after ->
    mockery.deregisterAll()
    mockery.disable()
