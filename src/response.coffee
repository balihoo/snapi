responder = require './responder'

exports.Response = class Response
  constructor: (@body = null, @headers = {}, @statusCode = 200) ->

exports.RedirectResponse = class RedirectResponse extends Response
  constructor: (@uri, @statusCode = 301) ->
    super null, Location: @uri, @statusCode
 