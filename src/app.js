var express = require('express')
var http = require('http')
var fs = require('fs')
var config = require('./config')
// var github = require('./lib/github-oauth')
var github = require('./lib/google-oauth')
var sessions = require("client-sessions")

var app = express()

console.log('Logcabin starting...')

app.use(sessions({ cookieName: 'session', secret: config.cookie_secret }))

github.setupOAuth(express, app, config)

proxyES()
proxyKibana()

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

function proxyKibana() {
    app.get('/config.js', function(request, response) {
        response.setHeader('Content-Type', 'application/javascript')
        var content = "define(['settings'],                                  "+
                      "function (Settings) {                                 "+
                      "    'use strict';                                     "+
                      "    return new Settings({                             "+
                      "        elasticsearch: '/__es',                       "+
                      "        default_route: '/dashboard/file/default.json',"+
                      "        kibana_index: 'kibana-int',                   "+
                      "        panel_names: ['histogram', 'map', 'pie', 'table', 'filtering', 'timepicker', 'text', 'hits', 'column', 'trends', 'bettermap', 'query', 'terms', 'sparklines']"+
                      "     });                                              "+
                      " });                                                  ";
        response.end(content)
    })

    /* Serve all kibana3 frontend files */
    app.use(express.compress())
    app.use('/', express.static(__dirname + '/../kibana', {maxAge: 0}))
}