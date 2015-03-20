'use strict'

exports.MissingApiConfigError =  MissingApiConfigError = ()->
  self = new Error "Required parameter 'api' not specified.  Must be an object or the path to your API documentation."
  self.name = 'MissingApiConfig'
  self.__proto__ = MissingApiConfigError.prototype
  self

MissingApiConfigError.prototype.__proto__= Error.prototype

exports.MissingRouteHandlersConfigError =  MissingRouteHandlersConfigError = ()->
  self = new Error "Required parameter 'routeHandlers' not specified.  Must be an object or the path to a module."
  self.name = 'MissingRouteHandlersConfig'
  self.__proto__ = MissingRouteHandlersConfigError.prototype
  self

MissingRouteHandlersConfigError.prototype.__proto__= Error.prototype

exports.MissingRouteHandlerError =  MissingRouteHandlerError = (operation)->
  self = new Error "No handler found for #{operation.method} #{operation.path}, operation ID #{operation.operationId}."
  self.name = 'MissingRouteHandler'
  self.path = operation.path
  self.method = operation.method
  self.operationId = operation.operationId
  self.__proto__ = MissingRouteHandlerError.prototype
  self

MissingRouteHandlerError.prototype.__proto__= Error.prototype