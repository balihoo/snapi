sinon = require 'sinon'
mockery = require 'mockery'

sandbox = null
exports.mocks = {}
exports.mocked = {}

exports.fakes =
  restify:
    createServer: () ->
    authorizationParser: ->
    queryParser: ->
    bodyParser: ->
    auditLogger: ->

  restifyServer:
    use: ->
    on: ->
    get: ->

exports.enable = ->
  mockery.enable useCleanCache: true
  mockery.warnOnUnregistered false
  
exports.disable = () ->
  mockery.deregisterAll()
  mockery.disable()
  sandbox.restore()
  sandbox = null
  exports.mocks = {}
  exports.mocked = {}
  
exports.mock = (path, implementation, internalOnly) ->
  if not sandbox
    sandbox = sinon.sandbox.create()
  
  implementation = implementation or require path
  mock = sandbox.mock implementation
  implementation._mocked = true
  
  mockery.registerMock path, implementation  unless internalOnly
  exports.mocked[path] = implementation
  exports.mocks[path] = mock

exports.mockInternal = (path, implementation) ->
  exports.mock path, implementation, true
  
exports.allow = (path) ->
  mockery.registerAllowable path, true

exports.verify = ->
  for key, mock of exports.mocks
    mock.verify()
