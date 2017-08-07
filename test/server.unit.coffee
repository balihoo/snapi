assert = require 'assert'
sinon = require 'sinon'
mocker = require './mocker'
simpleApi = require './simpleApi'
restify = require 'restify'

server = require '../src/server'

describe 'server unit tests', ->
  describe 'createServer', ->
    context 'when no API is supplied', ->
      it 'throws a MissingApiConfigError', ->
        sinon.stub restify, 'createServer'
        .returns mocker.fakes.restifyServer

        server.createServer
          routeHandlers:
            someHandler: ->
        .then ->
          assert.fail 'Expected MissingApiConfigError'
        .catch (err) ->
          assert.strictEqual err.name, 'MissingApiConfig'
        .finally restify.createServer.restore()

    context 'when no route handlers are provided', ->
      it 'throws a MissingRouteHandlersConfigError', ->
        sinon.stub restify, 'createServer'
        .returns mocker.fakes.restifyServer

        server.createServer api: simpleApi
        .then ->
          assert.fail 'Expected MissingRouteHandlersConfigError'
        .catch (err) ->
          assert.strictEqual err.name, 'MissingRouteHandlersConfig'
