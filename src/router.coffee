'use strict'
Promise = require 'bluebird'
swagger2 = require 'swagger2-utils'
error = require './error'

restifyMethod = (method) ->
  if method is 'delete' then 'del' else method

restifyPath = (path) ->
  path = path.split('{').join ':'
  path.split('}').join ''

registerRoute = (server, handler, method, path, operationId) ->
  method = restifyMethod method
  path = restifyPath path

  server[method] { url: path }, (request, response, next) ->
    routePromise = Promise.try ->
      # Hand off the request to the route's handler
      handler request

    # Send the route promise to the responder
    server.responder.respond routePromise, response, next

exports.registerRoutes = (server, apiSpec, opts) ->
  throw new error.MissingRouteHandlersConfigError  unless opts.routeHandlers
  
  routeHandlers = opts.routeHandlers
  if typeof routeHandlers is 'string'
    routeHandlers = require routeHandlers
  
  operations = swagger2.createOperationsList apiSpec

  for operation in operations
    if not routeHandlers[operation.operationId]?
      throw new Error "No handler found for path #{operation.path}, method #{operation.method}, operation #{operation.operationId}"

    registerRoute server, routeHandlers[operation.operationId], operation.method, operation.path, operation.operationId
