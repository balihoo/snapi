'use strict'
Bunyan = require 'bunyan'

###
  Define a special toJSON property for serializing Error objects
  Allows logging of custom properties including nested Error objects
###
errorToJson =
  configurable: true
  value: ->
    alt = {}
    storeKey = (key) ->
      alt[key] = this[key]

    Object.getOwnPropertyNames(@).forEach storeKey, @
    alt

Object.defineProperty Error.prototype, 'toJSON', errorToJson

module.exports = class Logger
  constructor: (opts) ->
    if opts.log.logger
      # User provided their own logger
      @log = opts.log.logger
    else
      # Use bunyan for logging
      logConfig = {}
      logConfig.name = opts.name or 'apish'
      logConfig.streams = opts.log.streams or [
        path: opts.log.path or './apish.log'
        type: opts.log.type or 'rotating-file'
        level: opts.log.level or 'debug'
        period: opts.log.period or '1d'
        count: opts.log.count or 10
      ]
      @log = new Bunyan logConfig

  unhandledRejection: (err) ->
    @log.error
      unhandledRejection: true
      err: err,
      err.message

  unhandledProcessException: (err) ->
    @log.fatal
      unhandledProcessException: true
      err: err,
      err.message

  unhandledRestifyException: (req, res, route, err) ->
    @log.error
      unhandledRestifyException: true
      req: req
      res: res
      route: route
      err: err,
      err.message

    res.send 500, 'Internal server error'

