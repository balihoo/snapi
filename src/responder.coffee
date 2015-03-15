'use strict'
Promise = require 'bluebird'
restify = require 'restify'

codes =
  successWithBody: 200
  successNoBody: 204
  internalError: 500
  invalidCredentials: 401
  notAuthorized: 403

module.exports = class Responder
  constructor: (@logger, opts) ->
    # If user has specified a responder use it
    @respond = opts.responder  if opts.responder

  errorResponse: (err, response, next) ->
    @logger.log.error err

    if err instanceof restify.InvalidCredentialsError
      response.header 'Www-Authenticate', 'Basic'

    next err

  respond: (result, response, next) ->
    if result instanceof Error
      @errorResponse result, response, next
    else
      Promise.cast result
      .then (result) ->
        response.header 'Content-Type', 'application/json; charset=utf-8'
        response.charSet = 'utf-8'
        
        if result
          response.json codes.successWithBody, result
        else
          response.send codes.successNoBody
          
        next()
      .catch (err) =>
        @errorResponse err, response, next

  codes: codes