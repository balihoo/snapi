'use strict'
Promise = require 'bluebird'
restify = require 'restify'
stream = require 'stream'
jsonStream = require 'JSONStream'

codes =
  successWithBody: 200
  successNoBody: 204
  internalError: 500
  invalidCredentials: 401
  notAuthorized: 403

module.exports = class Responder
  constructor: (@logger, @customRespond) ->

  errorResponse: (err, response, next) ->
    @logger.log.error err

    if err instanceof restify.InvalidCredentialsError
      response.header 'Www-Authenticate', 'Basic'

    next err

  respond: (result, response, next) ->
    if @customRespond
      @customRespond result, response, next
    else
      if result instanceof Error
        @errorResponse result, response, next
      else
        Promise.cast result
        .then (result) ->
          if result instanceof stream.Stream
            response.writeHead 200,
              'Content-Type': 'application/json; charset=utf-8'
              charset: 'utf-8'

            if result.objectMode or result._readableState?.objectMode
              result
              .pipe jsonStream.stringify()
              .pipe response
            else
              result.pipe response
          else
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