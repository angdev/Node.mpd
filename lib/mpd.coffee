net = require 'net'

class SocketState
	constructor: (socket, req) ->
		@socket = socket
		@req = req
		@buffer = new Buffer(0)
		@is_processing = false
		@is_processed = false
		@is_receiving = false
		@is_received = false

class MPD
	constructor: ->
		console.log 'MPD Constructed'
		#request queue init

	Init: =>
		@connection = net.createConnection {port: 6600}
		@connection.setEncoding 'utf-8'
		@connection.on 'connect', ->
	    	console.log 'Connected'
	    @connection.on 'data', @_onData

	    console.log 'MPD Init'
	    console.log 'queue init'
	    @state_queue = []
	    console.log 'Start process func'
	    setInterval @_process, 20
	    
	OnMpd: (socket, data) =>
		console.log data.cmd
		#일단은 가공없이 cmd만 보낸다 (cmd 가공은 왠만하면 클라에서 하는걸로)
		state = new SocketState(socket, data.cmd)
		@_pushState state

#dev
	#state에는 socket, req만 넣을 것
	_pushState: (state) =>
		if state == null
			return
		if state.socket == undefined || state.req == undefined
			return
		@state_queue.push state
		
	_popState: =>
		@state_queue.shift()
	
	_frontState: =>
		@state_queue[0]
	
	_process: =>
		if @state_queue.length <= 0
			return
		
		state = @_frontState()
		if !state.is_processed
			if !state.is_processing
				@connection.write state.req
				state.is_processing = true
				state.is_receiving = true
			else if state.is_received
				#console.log state.buffer.toString()
				state.socket.emit 'mpd', state.buffer.toString()
				state.is_processed = true
		else
			@_popState()
			
	_onData: (data) =>
		if @_frontState() != undefined
			@_frontState().buffer = Buffer.concat([@_frontState().buffer, new Buffer(data)])
			console.log data.substr(-3)
			if data.substr(-3) == 'OK\n'
				@_frontState().is_received = true
	
	_onEnd: =>
		console.log 'end\n'
	
#end_dev	


module.exports.MPD = MPD
