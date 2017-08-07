assert = require 'assert'
sinon = require 'sinon'
InvalidCredentialsError = require('restify').InvalidCredentialsError
Logger = require '../src/logger'
Responder = require '../src/responder'
Response = require('../src/response').Response

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
    context 'when a non-null result is passed', ->
      it 'responds with a body', (done) ->
        result = "somevalue"
        responder = new Responder logger

        mockResponse = sinon.mock response
        mockResponse.expects('send').once().withArgs responder.codes.successWithBody, result

        responder.respond result, response, ->
          mockResponse.verify()
          done()

    context 'when an undefined result is passed', ->
      it 'responds without a body', (done) ->
        responder = new Responder logger

        mockResponse = sinon.mock response
        mockResponse.expects('send').once().withArgs responder.codes.successNoBody

        responder.respond undefined, response, ->
          mockResponse.verify()
          done()

  context 'when a null result is passed', ->
    it 'responds without a body', (done) ->
      responder = new Responder logger

      mockResponse = sinon.mock response
      mockResponse.expects('send').once().withArgs responder.codes.successNoBody

      responder.respond null, response, ->
        mockResponse.verify()
        done()

  context 'when a Response object is passed', ->
    it "responds with the Response object's body, headers, and status code", (done) ->
      responder = new Responder logger

      body =
        some: 'stuff'
      
      headers =
        a: 'header'
        another: 'one'
        
      statusCode = 999
        
      r = new Response body, headers, statusCode
      mockResponse = sinon.mock response
      mockResponse.expects('send').once().withArgs statusCode, body

      responder.respond r, response, ->
        mockResponse.verify()
        done()

  context 'when an InvalidCredentialsError is passed', ->
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

  context 'when any other error is passed', ->
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

  afterEach ->
    mockLogger.restore()