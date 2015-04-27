module.exports = ->
  (request, response, next) ->
    if request.swagger.params
      for param, paramName of request.swagger.params
        if request.params[paramName]?
          param.value =request.params[paramName]
        
    next()