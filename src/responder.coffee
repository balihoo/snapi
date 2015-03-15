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
    # Send basic auth challenges by default
    @sendBasicAuthChallenge = true  unless opts.sendBasicAuthChallenge is false

    # If user has specified a responder use it
    @respond = opts.responder  if opts.responder

  errorResponse: (err, response, next) ->
    @logger.log.error err

    if err instanceof restify.InvalidCredentialsError and @sendBasicAuthChallenge
      response.header 'Www-Authenticate', 'Basic'

    next err

  respond: (maybePromise, response, next) ->
    if maybePromise instanceof Error
      @errorResponse maybePromise, response, next
    else
      Promise.cast maybePromise
      .then (result) =>
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