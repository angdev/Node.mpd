mpd_module = require './mpd'

mpd = new mpd_module.MPD()
mpd.Init()

sock = undefined

class SocketHandler
	constructor: ->
		console.log 'New Socket Init'
	Init: (sock) =>
		@socket = sock
		@socket.on 'test', @OnTest
		@socket.on 'currentsong', @OnCurrentSong
		@socket.on 'status', @OnStatus

	OnTest: (data) ->
		console.log 'test'

	OnCurrentSong: (data) =>
		mpd.GetCurrentSong(@socket)

	OnStatus: (data) =>
		mpd.GetStatus(@socket)

#register here
OnConnection = (socket) -> 
	sockHnd = new SocketHandler()
	sockHnd.Init(socket)

socket_init = (sockets) -> 
	sockets.on 'connection', OnConnection
	console.log "sockio inited"

module.exports.socket_init = socket_init