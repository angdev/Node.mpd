mpd_module = require './mpd'

mpd = new mpd_module.MPD()
mpd.Init()

sock = undefined

OnTest = (data) ->
	console.log 'test'

OnCurrentSong = (data) ->
	mpd.GetCurrentSong(sock)

OnStatus = (data) ->
	mpd.GetStatus(sock)

#register here
OnConnection = (socket) -> 
	sock = socket
	socket.on 'test', OnTest
	socket.on 'currentsong', OnCurrentSong
	socket.on 'status', OnStatus

socket_init = (sockets) -> 
	sockets.on 'connection', OnConnection
	console.log "sockio inited"

module.exports.socket_init = socket_init