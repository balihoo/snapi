assert = require 'assert'
router = require '../lib/router'
server = require '../lib/server'
simpleApi = require './simpleApi'

fakeServer = undefined

describe 'router unit tests', ->
  describe 'registerRoutes()', ->
    context 'when route handler config is missing', ->
      it 'throws a MissingRouteHandlersConfig error', (done) ->
        fakeServer = server.createServer api: simpleApi, routeHandlers: getUsers: ->
        opts = foo: "bar"

        try
          router.registerRoutes fakeServer, simpleApi, opts
        catch err
          assert.strictEqual err.name, 'MissingRouteHandlersConfig'
        finally
          done()

    context 'when route handler is missing', ->
      it 'throws a MissingRouteHandler error', (done) ->
        fakeServer = server.createServer api: simpleApi, routeHandlers: getUsers: ->
        opts = routeHandlers: "foo"

        try
          router.registerRoutes fakeServer, simpleApi, opts
        catch err
          assert.strictEqual err.name, 'MissingRouteHandler'
        finally
          done()


    context 'when route handler exists', ->
      it 'is not rejected', (done) ->
        fakeServer = server.createServer api: simpleApi, routeHandlers: getUsers: ->
        opts = routeHandlers: getUsers: ->

        results = router.registerRoutes fakeServer, simpleApi, opts
        for result in results
          assert.strictEqual result.isRejected(), false
        done()

  describe 'simplifySwaggerParams()', ->
    context 'when no params are provided', ->
      it 'returns an empty object', (done) ->
        params = router.simplifySwaggerParams()

        assert.deepEqual params, {}
        done()

    context 'when passed a string type', ->
      it 'returns the value formatted as a string', (done) ->
        fakeSwaggerParams =
          foo:
            schema: type: "string"
            value: "bar"
        expected = foo: "bar"

        params = router.simplifySwaggerParams(fakeSwaggerParams)

        assert.deepEqual params, expected
        assert.equal typeof params.foo, "string"
        done()

    context 'when passed a number type', ->
      it 'returns the value formatted as a number', (done) ->
        fakeSwaggerParams =
          foo:
            schema: type: "number"
            value: "1.99"
        expected = foo: 1.99

        params = router.simplifySwaggerParams(fakeSwaggerParams)

        assert.deepEqual params, expected
        assert.equal typeof params.foo, "number"
        done()

    context 'when passed an integer type', ->
      it 'returns the value formatted as a number', (done) ->
        fakeSwaggerParams =
          foo:
            schema: type: "integer"
            value: "199"
        expected = foo: 199

        params = router.simplifySwaggerParams(fakeSwaggerParams)

        assert.deepEqual params, expected
        assert.equal typeof params.foo, "number"
        done()

    context 'when passed a truthy boolean type', ->
      it 'returns a boolean true', (done) ->
        fakeSwaggerParams =
          foo:
            schema: type: "boolean"
            value: "true"
        expected = foo: true

        params = router.simplifySwaggerParams(fakeSwaggerParams)

        assert.deepEqual params, expected
        assert.equal typeof params.foo, "boolean"
        done()

    context 'when passed a falsey boolean type', ->
      it 'returns a boolean false', (done) ->
        fakeSwaggerParams =
          foo:
            schema: type: "boolean"
            value: "false"
        expected = foo: false

        params = router.simplifySwaggerParams(fakeSwaggerParams)

        assert.deepEqual params, expected
        assert.equal typeof params.foo, "boolean"
        done()

    context 'when passed a non boolean type', ->
      it 'returns original value unchanged', (done) ->
        fakeSwaggerParams =
          foo:
            schema: type: "boolean"
            value: "500"
        expected = foo: "500"

        params = router.simplifySwaggerParams(fakeSwaggerParams)

        assert.deepEqual params, expected
        assert.equal typeof params.foo, "string"
        done()
