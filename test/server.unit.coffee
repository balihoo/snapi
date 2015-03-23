assert = require 'assert'
sinon = require 'sinon'
mocker = require './mocker'
simpleApi = require './simpleApi'

server = undefined
mocks = undefined
mocked = undefined
fakeErr = new Error "loud noises!"

describe 'server unit tests', ->
  beforeEach ->
    mocker.mock 'bluebird'
    mocker.mock 'swagger-tools'
    mocker.mock 'restify', mocker.fakes.restify
    mocker.mock '../lib/logger'
    mocker.mock '../lib/responder'
    mocker.mock '../lib/router'
    mocker.mock '../lib/error'
    mocker.mockInternal 'restifyServer', mocker.fakes.restifyServer
    mocker.allow '../lib/server'
    mocker.enable()
    server = require '../lib/server'
    mocks = mocker.mocks
    mocked = mocker.mocked

  describe 'createServer', ->
    context 'when no API is supplied', ->
      it 'throws a MissingApiConfigError', ->
        mocks.restify.expects 'createServer'
        .once()
        .returns mocked.restifyServer

        server.createServer
          routeHandlers:
            someHandler: ->
        .then ->
          assert.fail 'Expected MissingApiConfigError'
        .catch (err) ->
          assert.strictEqual err.name, 'MissingApiConfig'

    context 'when no route handlers are provided', ->
      it 'throws a MissingRouteHandlersConfigError', ->
        mocks.restify.expects 'createServer'
        .once()
        .returns mocked.restifyServer

        server.createServer api: simpleApi
        .then ->
          assert.fail 'Expected MissingRouteHandlersConfigError'
        .catch (err) ->
          assert.strictEqual err.name, 'MissingRouteHandlersConfig'

#    context 'when a route handler is missing', ->
#      it 'throws a MissingRouteHandlerError', ->
#        mocks.restify.expects 'createServer'
#        .once()
#        .returns mocked.restifyServer
#
#        mocks['swagger-tools'].expects 'initializeMiddleware'
#
#        server.createServer(api: simpleApi, routeHandlers: getStuff: ->)
#        .then ->
#          assert.fail 'Expected MissingRouteHandlerError'
#        .catch (err) ->
#          assert.strictEqual err.name, 'MissingRouteHandler'
#
#    context 'when parsers are not specified', ->
#      it 'creates a server with the default parsers', ->
#        bodyParser = ->
#        authorizationParser = ->
#        queryParser = ->
#
#        mocks.restify.expects 'createServer'
#        .returns mocked.restifyServer
#
#        mocks['swagger-tools'].expects 'initializeMiddleware'
#
#        mocks.restify.expects 'bodyParser'
#        .once()
#        .withArgs mapParams: false
#        .returns bodyParser
#
#        mocks.restify.expects 'authorizationParser'
#        .once()
#        .returns authorizationParser
#
#        mocks.restify.expects 'queryParser'
#        .once()
#        .returns queryParser
#
#        mocks.restifyServer.expects 'use'
#        .withArgs bodyParser
#        .once()
#
#        mocks.restifyServer.expects 'use'
#        .withArgs authorizationParser
#        .once()
#
#        mocks.restifyServer.expects 'use'
#        .withArgs queryParser
#        .once()
#
#        server.createServer api: simpleApi, routeHandlers: getUsers: ->
#
#    context 'when parsers are specified', ->
#      it 'creates a server with the specified parsers', ->
#        result1 = {}
#        result2 = {}
#
#        parser1 =
#          parser: ->
#            result1
#          options: stuff: 'things'
#
#        parser2 =
#          parser: ->
#            result2
#          options: other: 'things'
#
#        mocks.restify.expects 'createServer'
#        .returns mocked.restifyServer
#
#        mocks['swagger-tools'].expects 'initializeMiddleware'
#
#        mocks.restifyServer.expects 'use'
#        .withArgs result1
#        .once()
#
#        mocks.restifyServer.expects 'use'
#        .withArgs result2
#        .once()
#
#        server.createServer
#          api: simpleApi
#          parsers: [parser1, parser2]
#          routeHandlers: getUsers: ->


  afterEach ->
    mocker.verify()
    mocker.disable()
