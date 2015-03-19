assert = require 'assert'
sinon = require 'sinon'
mockery = require 'mockery'
bluebird = require 'bluebird'
swaggerTools = require 'swagger-tools'
error = require '../lib/error'
logger = require '../lib/logger'
responder = require '../lib/responder'
router = require '../lib/router'

server = undefined
mockLogger = sinon.mock logger
mockResponder = sinon.mock responder
mockRouter = sinon.mock router
mockSwaggerTools = sinon.mock swaggerTools

restify =
  createServer: () ->
    use: ->
    on: ->
  authorizationParser: ->
  queryParser: ->
  bodyParser: ->
  auditLogger: ->

mockRestify = sinon.mock restify
restify.blergh = 'blergh'
mockBluebird = sinon.mock bluebird

fakeErr = new Error "loud noises!"

describe 'server unit tests', ->
  before ->
    mockery.enable useCleanCache: true
    mockery.registerMock 'bluebird', bluebird
    mockery.registerMock './logger', logger
    mockery.registerMock './responder', responder
    mockery.registerMock './router', router
    mockery.registerMock 'swagger-tools', swaggerTools
    mockery.registerMock 'restify', restify
    mockery.registerAllowable './error'
    mockery.registerAllowable '../lib/server'
    server = require '../lib/server'
    
  describe 'createServer', ->
    context 'when no options are supplied', ->
      it 'throws a MissingApiConfigError', ->
        try
          server.createServer()
          assert.fail 'Expected MissingApiConfigError'
        catch err
          assert.strictEqual err.name, 'MissingApiConfig'
          
  after ->
    mockery.deregisterAll()
    mockery.disable()