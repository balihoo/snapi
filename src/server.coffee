'use strict'
Promise = require 'bluebird'
restify = require 'restify'
swaggerTools = require 'swagger-tools'
Logger = require './logger'
Responder = require './responder'
router = require './router'
error = require './error'

addParsers = (server, parsers) ->
  if Array.isArray parsers
    # User specified parsers to use
    for parser in parsers
      server.use parser.parser(parser.options)
  else
    # Use the default parsers
    server.use restify.bodyParser(mapParams: false)
    server.use restify.authorizationParser()
    server.use restify.queryParser()

configureLogging = (server, opts) ->
  logger = new Logger opts

  # Set up logging
  server.on 'after', restify.auditLogger
    name: 'audit'
    log: logger.log

  Promise.onPossiblyUnhandledRejection logger.unhandledRejection
  process.on 'uncaughtException', logger.unhandledProcessException
  server.on 'uncaughtException', logger.unhandledRestifyException
  server.logger = logger

setApi = (server, opts) ->
  throw new error.MissingApiConfigError()  unless opts.api

  apiSpec = opts.api
  apiSpec = require opts.api  if typeof opts.api is 'string'

  swaggerTools.initializeMiddleware apiSpec, (middleware) ->
    # Interpret Swagger resources and attach metadata to request.swagger
    server.use middleware.swaggerMetadata()

  # Add routes
  router.registerRoutes server, apiSpec, opts

exports.createServer = (opts) ->
  opts = opts or {}
  server = restify.createServer opts

  addParsers server, opts.parsers
  configureLogging server, opts
  server.responder = new Responder server.logger, opts.responder
  setApi server, opts

  server
