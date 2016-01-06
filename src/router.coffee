'use strict'
Promise = require 'bluebird'
swagger2 = require 'swagger2-utils'
error = require './error'

restifyMethod = (method) ->
  if method is 'delete' then 'del' else method

restifyPath = (path) ->
  path = path.split('{').join ':'
  path.split('}').join ''

simplifySwaggerParams = (swaggerParams = {}) ->
  params = {}
  
  for paramName, param of swaggerParams
    # The swagger library leaves numbers and booleans as strings when they're in the querystring or path, so fix them
    switch param.schema?.type
      when 'number', 'integer'
        param.value = param.value - 0  if typeof param.value isnt 'number'
      when 'boolean'
        param.value = not not param.value  if typeof param.value isnt 'boolean'
    
    params[paramName] = param.value
    
  params
  
registerRoute = (server, method, path, handler) ->
  method = restifyMethod method
  path = restifyPath path

  server[method] { url: path }, (request, response, next) ->
    Promise.try ->
      # Create a simplified and type-corrected params object based on the swagger param data
      params = simplifySwaggerParams request?.swagger?.params
      
      # Hand off the request and params to the route's handler
      handler request, params

    .then (result) ->
      # Send the result to the responder
      server.responder.respond result, response, next
    .catch (err) ->
      server.responder.errorResponse err, response, next

exports.registerRoutes = (server, apiSpec, opts) ->
  throw new error.MissingRouteHandlersConfigError  unless opts.routeHandlers
  
  routeHandlers = opts.routeHandlers
  operations = swagger2.createOperationsList apiSpec

  for operation in operations
    if not routeHandlers[operation.operationId]?
      throw new error.MissingRouteHandlerError operation

    registerRoute server, operation.method, operation.path, routeHandlers[operation.operationId]
