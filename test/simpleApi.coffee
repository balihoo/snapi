module.exports =
  swagger: "2.0"
  info:
    version: "0.0.0"
    title: "My API"
    description: "This is my API"
  host: "localhost"
  schemes: [
    "http"
    "https"
  ]
  securityDefinitions:
    basicAuth:
      type: "basic"
      description: "HTTP Basic Authentication."
  consumes: [
    "application/json"
  ]
  produces: [
    "application/json"
  ]
  paths:
    "/user":
      "get":
        "security": [
            "basicAuth": []
        ]
        "description": "Return all users."
        "operationId": "getUsers"
        "responses":
          "200":
            "description": "list of sources"
            "schema":
              "type": "array"
              "items":
                "type": "string"
