'use strict'
Promise = require 'bluebird'
swagger2 = require 'swagger2-utils'
error = require './error'

restifyMethod = (method) ->
  if method is 'delete' then 'del' else method

restifyPath = (path) ->
  path = path.split('{').join ':'
  path.split('}').join ''

registerRoute = (server, method, path, handler) ->
  method = restifyMethod method
  path = restifyPath path

  server[method] { url: path }, (request, response, next) ->
    Promise.try ->
      # Hand off the request to the route's handler
      handler request

    .then (result) ->
      # Send the result to the responder
      server.responder.respond result, response, next
    .catch (err) =>
      server.responder.errorResponse err, response, next

exports.registerRoutes = (server, apiSpec, opts) ->
  throw new error.MissingRouteHandlersConfigError  unless opts.routeHandlers
  
  routeHandlers = opts.routeHandlers
  operations = swagger2.createOperationsList apiSpec

  for operation in operations
    if not routeHandlers[operation.operationId]?
      throw new error.MissingRouteHandlerError operation

    registerRoute server, operation.method, operation.path, routeHandlers[operation.operationId]
