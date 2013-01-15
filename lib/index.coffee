express = require 'express'
sockio = require './sockio'

app = express()

server = require('http').createServer app
socket = require('socket.io').listen server
socket.configure -> 
	socket.set "transports", ["xhr-polling"]
	socket.set "polling duration", 10

app.set 'views', __dirname + '/../views'
app.set 'view engine', 'ejs'
app.set 'view options', {
        layout: false
}
app.use "/static", express.static __dirname + '/../static'

sockio.socket_init socket.sockets

app.get '/', (req, res) ->
        res.render 'index'

server.listen 3000