'use strict'
Promise = require 'bluebird'
errors = require 'restify-errors'
stream = require 'stream'
jsonStream = require 'JSONStream'
Response = require('./response').Response

codes =
  successWithBody: 200
  successNoBody: 204
  movedPermanently: 301
  found: 302
  internalError: 500
  invalidCredentials: 401
  notAuthorized: 403
  
module.exports = class Responder
  constructor: (@logger) ->

  errorResponse: (err, response, next) ->
    @logger.log.error err

    if err instanceof errors.InvalidCredentialsError
      response.header 'Www-Authenticate', 'Basic'

    next err

  respondStream: (result, response) ->
    response.writeHead 200, 'Content-Type': 'application/json; charset=utf-8'

    if result.objectMode or result._readableState?.objectMode
      result
      .pipe jsonStream.stringify()
      .pipe response
    else
      result.pipe response

  respond: (result, response, next) ->
    if result instanceof Error
      return @errorResponse result, response, next
      
    if result instanceof stream.Stream
      return @respondStream result, response

    # Send the result as the body and 200 or 204 based on result being defined and non-null
    body = result
    statusCode = if result? then codes.successWithBody else codes.successNoBody

    if result instanceof Response
      # Override the default behavior, allowing the caller to specify response code, headers, and body
      for header, value of result.headers
        response.header header, value
        
      body = result.body
      statusCode = result.statusCode

    response.send statusCode, body
    next()
    
  codes: codes