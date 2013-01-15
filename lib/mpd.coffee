net = require 'net'

class MPD
	constructor: ->
		console.log 'MPD Constructed'

	Init: ->
		@connection = net.createConnection {port: 6600}
		@connection.setEncoding 'utf-8'
		@connection.on 'connect', ->
	    	console.log 'Connected'
	    console.log 'MPD Init'

	GetCurrentSong: (socket) ->
		@connection.on 'data', (data) -> 
			socket.emit 'currentsong', data
		@connection.write 'currentsong\n'

	GetStatus: (socket) ->
		@connection.on 'data', (data) ->
			socket.emit 'status', data
		@connection.write 'status\n'

module.exports.MPD = MPD