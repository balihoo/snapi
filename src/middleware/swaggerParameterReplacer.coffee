module.exports = ->
  (request, response, next) ->
    if request?.swagger?.params
      for paramName, param of request.swagger.params
        if request.params[paramName]?
          param.value =request.params[paramName]
        
    next()