net = require 'net'

class MPD
	constructor: ->
		console.log 'MPD Constructed'
		#request queue init

	Init: =>
		@connection = net.createConnection {port: 6600}
		@connection.setEncoding 'utf-8'
		@connection.on 'connect', ->
	    	console.log 'Connected'
	    @connection.on 'data', (data) =>
	    	handler = @getCurrentHandler()
	    	if handler != undefined
	    		handler.listenFunc(data)

	    console.log 'MPD Init'
	    console.log 'queue init'
	    @request_queue = []
	    @is_data_received = true
	    console.log 'Start process func'
	    setInterval @process, 20

		
	GetPlaylistInfo: (socket, param) =>
		@cmd = 'playlistinfo'
		if param.start != undefined
			@cmd += (' ' + param.start + ':' + param.end + '\n');
		else
			@cmd += '\n'
		
		listenFunc = (data) =>
			@getCurrentSocket().emit 'playlistinfo', data
		requestFunc = =>
			@connection.write @cmd
		@pushHandler @createHandler(listenFunc, requestFunc, socket)

	

	#private funcion
	#handler -> (listenFunc, requestFunc)
	createHandler: (listenFunc, requestFunc, socket) =>
		handler = {}
		handler.listenFunc = @onFuncDecorator listenFunc
		handler.requestFunc = @requestFuncDecorator requestFunc
		handler.socket = socket
		handler

	pushHandler: (handler) =>
		console.log handler.requestFunc.toString() + ' + 1 pushed'
		@request_queue.push handler

	popHandler: =>
		console.log 'popped'
		@request_queue.shift()

	handle: =>
		if @request_queue.length <= 0
			return

		handler = @getCurrentHandler()
		handler.requestFunc()

	#process work in work queue
	process: =>
		if @is_data_received == true
			@handle()
			return

	getCurrentHandler: =>
		if @request_queue[0] != undefined
			return @request_queue[0]

	getCurrentSocket: =>
		if @request_queue[0] != undefined and @request_queue[0].socket != undefined
			return @request_queue[0].socket

	onFuncDecorator: (func) =>
		decoratedFunc = (data) =>
				func(data)
				@popHandler()
				@is_data_received = true
		decoratedFunc

	requestFuncDecorator: (func) =>
		decoratedFunc = (data) =>
			@is_data_received = false
			func(data)
		decoratedFunc


module.exports.MPD = MPD
