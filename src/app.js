var express = require('express')
var http = require('http')
var fs = require('fs')
var config = require('./config')
var auth = require('./lib/auth')
var sessions = require("client-sessions")

var app = express()

console.log('Logcabin starting...')

app.use(sessions({ cookieName: 'session', secret: config.cookie_secret }))

auth.setup(express, app, config)

proxyES()
proxyKibana4()

http.createServer(app).listen(config.listen_port)
console.log('Logcabin listening on ' + config.listen_port)

function proxyES() {
    app.use("/__es", function(request, response, next) {

      var proxyRequest = http.request({host: config.es_host, port: config.es_port, path: request.url, method: request.method, headers: request.headers}, function(proxyResponse) {
          response.writeHead(proxyResponse.statusCode, proxyResponse.headers)
          proxyResponse.pipe(response)
      })
      request.pipe(proxyRequest)
  })
}

function proxyKibana4() {
    app.use("/", function(request, response, next) {

      var proxyRequest = http.request({host: config.kibana_host, port: config.kibana_port, path: request.url, method: request.method, headers: request.headers}, function(proxyResponse) {
          response.writeHead(proxyResponse.statusCode, proxyResponse.headers)
          proxyResponse.pipe(response)
      })
      request.pipe(proxyRequest)
  })
}
