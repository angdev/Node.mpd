net = require 'net'
express = require 'express'

app = express()

server = require('http').createServer app
sockio = require('socket.io').listen server

app.set 'view engine', 'jade'

connection = net.createConnection {port: 6600}
connection.setEncoding 'utf-8'

mpd_state = ''

connection.on 'connect', ->
        console.log 'Connected'

connection.on 'data', (data)->
        console.log data
        mpd_state = data

sockio.sockets.on 'connection', (socket) ->
        console.log 'socket.io connected'

app.get '/', (req, res) ->
        res.render 'index'


server.listen 3000
