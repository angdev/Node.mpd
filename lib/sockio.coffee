mpd_module = require './mpd'

mpd = new mpd_module.MPD()
mpd.Init()

class SocketHandler
	constructor: ->
		console.log 'New Socket Init'
	Init: (sock) =>
		@socket = sock
		@socket.on 'mpd', @_onMpd

	_onMpd: (data) =>
		console.log data
		#@socket.emit 'mpd', data
		mpd.OnMpd(@socket, data)

#register here
OnConnection = (socket) -> 
	sockHnd = new SocketHandler()
	sockHnd.Init(socket)

socket_init = (sockets) -> 
	sockets.on 'connection', OnConnection
	console.log "sockio inited"

module.exports.socket_init = socket_init