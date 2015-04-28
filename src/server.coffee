'use strict'
Promise = require 'bluebird'
restify = require 'restify'
swaggerTools = require 'swagger-tools'
Logger = require './logger'
Responder = require './responder'
router = require './router'
error = require './error'
swaggerParameterReplacer = require './middleware/swaggerParameterReplacer'

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

addMiddleware = (server, middleware) ->
  if Array.isArray middleware
    for middlewareFunc in middleware
      if typeof middlewareFunc is 'function'
        server.use middlewareFunc

configureLogging = (server, opts) ->
  logger = new Logger opts

  # Set up logging
  server.on 'after', restify.auditLogger
    name: 'audit'
    log: logger.log

  Promise.onPossiblyUnhandledRejection logger.unhandledRejection()
  process.on 'uncaughtException', logger.unhandledProcessException()
  server.on 'uncaughtException', logger.unhandledRestifyException()
  server.logger = logger

initializeSwagger = (server, opts) ->
  throw new error.MissingApiConfigError()  unless opts.api
  
  new Promise (resolve) ->
    swaggerTools.initializeMiddleware opts.api, (swaggerMiddleware) ->
      # Interpret Swagger resources and attach metadata to request.swagger
      server.use swaggerMiddleware.swaggerMetadata()
  
      # Validate requests against the swagger metadata
      server.use swaggerMiddleware.swaggerValidator()
      
      # Replace the swagger parameter values with those provided by restify since swagger doesn't URLdecode
      server.use swaggerParameterReplacer()
      
      resolve()

exports.createServer = (opts) ->
  server = undefined
  
  Promise.try ->
    opts = opts or {}
    opts.restify = opts.restify or {}
    opts.middleware = opts.middleware or {}
  
    server = restify.createServer opts.restify
  
    addParsers server, opts.parsers
    addMiddleware server, opts.middleware.afterParsers
    configureLogging server, opts
  
    server.responder = new Responder server.logger, opts.responder
    initializeSwagger server, opts
  .then ->
    addMiddleware server, opts.middleware.beforeRoutes

    # Add routes
    router.registerRoutes server, opts.api, opts

    # Add static serving if specified
    if opts.serveStatic
      server.get opts.serveStatic.url, restify.serveStatic opts.serveStatic
  .return server
