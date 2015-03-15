assert = require 'assert'
sinon = require 'sinon'
mockery = require 'mockery'

Logger = undefined
mockBunyan = sinon.spy()

describe 'logger unit tests', ->
  describe 'constructor', ->
    before ->
      mockery.enable()
      mockery.registerAllowable '../lib/logger'
      mockery.registerMock 'bunyan', mockBunyan
      Logger = require '../lib/logger'

    context 'when a logger is supplied', ->
      it 'uses the supplied logger', ->
        Logger = require '../lib/logger'

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
        Logger = require '../lib/logger'

        logger = new Logger {}
        assert.ok mockBunyan.calledOnce
        assert.ok mockBunyan.calledWith
          name: 'apish'
          streams: [
            path: './apish.log'
            type: 'rotating-file'
            level: 'warn'
            period: '1d'
            count: 10
          ]
    after ->
      mockery.disable()