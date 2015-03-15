'use strict'
Promise = require 'bluebird'
restify = require 'restify'
swaggerTools = require 'swagger-tools'
Logger = require './logger'
Responder = require './responder'
router = require './router'
error = require './error'

addParsers = (server, opts) ->
  if opts.parsers
    # User specified parsers to use
    for parser, parserOpts of opts.parsers
      if typeof parser is 'string'
        switch parser.toLowerCase()
          when 'body' then server.use restify.bodyParser(parserOpts)
          when 'authorization' then server.use restify.authorizationParser(parserOpts)
          when 'query' then server.use restify.queryParser(parserOpts)

  else
    # Use the default parsers
    server.use restify.bodyParser(mapParams: false)
    server.use restify.authorizationParser()
    server.use restify.queryParser()

configureLogging = (server, opts) ->
  opts.log = opts.log or {}
  logger = new Logger opts

  # Set up logging
  server.on 'after', restify.auditLogger
    name: 'audit'
    log: logger.log

  Promise.onPossiblyUnhandledRejection(opts.log.unhandledErrorHandler or logger.unhandledRejection)
  process.on 'uncaughtException', (opts.log.unhandledErrorHandler or logger.unhandledProcessException)
  server.on 'uncaughtException', (opts.log.unhandledErrorHandler or logger.unhandledRestifyException)
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
  
  addParsers server, opts
  configureLogging server, opts
  server.responder = new Responder server.logger, opts
  setApi server, opts

  server
