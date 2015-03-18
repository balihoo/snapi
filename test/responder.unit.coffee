assert = require 'assert'
sinon = require 'sinon'
Promise = require 'bluebird'
InvalidCredentialsError = require('restify').InvalidCredentialsError
Logger = require '../lib/logger'
Responder = require '../lib/responder'

logger = undefined
response = undefined

customLogger =
  error: ->
  info: ->
  fatal: ->
  
mockLogger = undefined

describe 'responder unit tests', ->
  beforeEach ->
    mockLogger = sinon.mock customLogger
    logger = new Logger
      log:
        logger: customLogger

    response =
      header: ->
      charSet: null
      json: ->
      send: ->

  describe 'constructor', ->
    context 'when a custom respond function is supplied', ->
      it 'uses the supplied function', ->
        respond = sinon.spy()
        result = 'somevalue'
        next = ->

        responder = new Responder logger, respond
        responder.respond result, response, next
        
        assert.ok respond.calledOnce
        assert.ok respond.calledWith result, response, next

    context 'when no custom respond function is supplied', ->
      context 'and a concrete truthy result is passed', ->
        it 'responds with a body', (done) ->
          result = "somevalue"
          responder = new Responder logger
          
          mockResponse = sinon.mock response
          mockResponse.expects('header').once().withArgs 'Content-Type', 'application/json; charset=utf-8'
          mockResponse.expects('json').once().withArgs responder.codes.successWithBody, result

          next = ->
            mockResponse.verify()
            assert.strictEqual response.charSet, 'utf-8'
            done()            
          
          responder.respond result, response, next

      context 'and a concrete falsy result is passed', ->
        it 'responds without a body', (done) ->
          result = ""
          responder = new Responder logger

          mockResponse = sinon.mock response
          mockResponse.expects('header').once().withArgs 'Content-Type', 'application/json; charset=utf-8'
          mockResponse.expects('send').once().withArgs responder.codes.successNoBody

          next = ->
            mockResponse.verify()
            assert.strictEqual response.charSet, 'utf-8'
            done()

          responder.respond result, response, next

      context 'and an InvalidCredentialsError is passed', ->
        it 'adds an auth challenge header and passes the error to next()', (done) ->
          fakeError = new InvalidCredentialsError 'Loud noises!'
          responder = new Responder logger

          mockResponse = sinon.mock response
          mockResponse.expects('header').once().withArgs 'Www-Authenticate', 'Basic'
          mockLogger.expects('error').once().withArgs fakeError
          
          next = (err) ->
            assert.strictEqual err, fakeError
            mockResponse.verify()
            mockLogger.verify()
            done()

          responder.respond fakeError, response, next

      context 'and any other error is passed', ->
        it 'passes the error to next()', (done) ->
          fakeError = new Error 'Loud noises!'
          responder = new Responder logger

          mockResponse = sinon.mock response
          mockResponse.expects('header').never()
          mockLogger.expects('error').once().withArgs fakeError
          
          next = (err) ->
            assert.strictEqual err, fakeError
            mockResponse.verify()
            mockLogger.verify()
            done()

          responder.respond fakeError, response, next
          
      context 'and a promise that resolves to a truthy value is passed', ->
        it 'responds with a body', (done) ->
          result = "somevalue"
          responder = new Responder logger

          mockResponse = sinon.mock response
          mockResponse.expects('header').once().withArgs 'Content-Type', 'application/json; charset=utf-8'
          mockResponse.expects('json').once().withArgs responder.codes.successWithBody, result
          mockLogger.expects('error').never()
          
          next = ->
            mockResponse.verify()
            mockLogger.verify()
            assert.strictEqual response.charSet, 'utf-8'
            done()

          responder.respond Promise.resolve(result), response, next

      context 'and a promise that resolves to a falsy result is passed', ->
        it 'responds without a body', (done) ->
          result = ""
          responder = new Responder logger

          mockResponse = sinon.mock response
          mockResponse.expects('header').once().withArgs 'Content-Type', 'application/json; charset=utf-8'
          mockResponse.expects('send').once().withArgs responder.codes.successNoBody
          mockLogger.expects('error').never()
          
          next = ->
            mockResponse.verify()
            mockLogger.verify()
            assert.strictEqual response.charSet, 'utf-8'
            done()

          responder.respond Promise.resolve(result), response, next

      context 'and a promise that rejects with an InvalidCredentialsError is passed', ->
        it 'adds an auth challenge header and passes the error to next()', (done) ->
          fakeError = new InvalidCredentialsError 'Loud noises!'
          responder = new Responder logger

          mockResponse = sinon.mock response
          mockResponse.expects('header').once().withArgs 'Www-Authenticate', 'Basic'
          mockLogger.expects('error').once().withArgs fakeError

          next = (err) ->
            assert.strictEqual err, fakeError
            mockResponse.verify()
            mockLogger.verify()
            done()

          responder.respond Promise.reject(fakeError), response, next

      context 'and a promise that rejects with any other error is passed', ->
        it 'passes the error to next()', (done) ->
          fakeError = new Error 'Loud noises!'
          responder = new Responder logger

          mockResponse = sinon.mock response
          mockResponse.expects('header').never()
          mockLogger.expects('error').once().withArgs fakeError
          
          next = (err) ->
            assert.strictEqual err, fakeError
            mockResponse.verify()
            mockLogger.verify()
            done()

          responder.respond Promise.reject(fakeError), response, next
          
  afterEach ->
    mockLogger.restore()