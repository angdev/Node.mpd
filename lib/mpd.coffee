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

	GetCurrentSong: (socket) =>
		listenFunc = (data) => 
			@getCurrentSocket().emit 'currentsong', data
		requestFunc = =>
			@connection.write 'currentsong\n'
		handler = {}
		handler.listenFunc = @onFuncDecorator listenFunc
		handler.requestFunc = requestFunc
		handler.socket = socket
		@pushHandler handler

	GetStatus: (socket) =>
		listenFunc = (data) => 
			@getCurrentSocket().emit 'status', data
		requestFunc = =>
			@connection.write 'status\n'
		handler = {}
		handler.listenFunc = @onFuncDecorator listenFunc
		handler.requestFunc = requestFunc
		handler.socket = socket
		@pushHandler handler


	#private funcion
	#handler -> (listenFunc, requestFunc)
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
		@requestFuncDecorator(handler.requestFunc)()

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