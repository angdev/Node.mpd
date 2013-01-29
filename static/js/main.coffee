#dev
class SocketWrapper
	constructor: ->
		@socket = io.connect location.host
		console.log 'socket connected.'
	
	RegisterListener: (type, listener) =>
		@socket.on type, listener
		
	Socket: =>
		@socket

class MessageQueue
	constructor: () ->
		@socket_wrap = new SocketWrapper()
		@queue = []
		@type_callback_dict = {}
		console.log 'RequestQueue Constructed'
		setInterval @_process, 20
	
	RegisterListener: (type, callback) =>
		@socket_wrap.RegisterListener type, @_onMessage
		@type_callback_dict[type] = callback
		console.log (type + ' listener registered.')
	
	PushRequest: (req) =>
		#check valid
		if req == null
			return
		if req.type == undefined || req.data == undefined
			return
		handler = {}
		handler['req'] = req
		handler['is_processing'] = false
		handler['is_processed'] = false
		@queue.push handler
	
	_popRequest: =>
		@queue.shift()
		
	_frontRequest: =>
		@queue[0]
	
	_onMessage: (data) =>
		console.log 'onMsg'
		handler = @_frontRequest()
		ret_arr = {}
		ret_arr['data'] = data;
		ret_arr['callback'] = handler.req.callback
		@type_callback_dict[handler.req.type](ret_arr)
		handler.is_processed = true;
	
	_process: =>
		if @queue.length <= 0
			return
		if @socket == null
			return
		
		console.log 'process'
		
		handler = @_frontRequest()
		if !handler.is_processed
			if !handler.is_processing
				@socket_wrap.Socket().emit handler.req.type, handler.req.data
				handler.is_processing = true
			else
				return
		else
			@_popRequest()
		
	
class MpdService
	constructor: (msg_queue) ->
		console.log 'Mpd Service start'
		msg_queue.RegisterListener "mpd", @_onMpd
		
	_onMpd: (ret_arr) =>
		ret_arr.callback(ret_arr.data)
		
	_parseMpdData: (data) =>
		splited = data.split '\n'
		parsed = {}
		for list in splited
			do (list) ->
				t = list.split ':'
				return if typeof t[1] is not String or t[1] is undefined
				parsed[t[0]] = t[1].substr(1)
		parsed

#end_dev

class TestModule
	constructor: (msg_queue) ->
		console.log 'TestModule Start'
		@queue = msg_queue
	
	__mpdTest: (_cmd, _data, _callback) =>
		req = {}
		req['type'] = "mpd"
		req['data'] = { cmd: _cmd, data: _data }
		req['callback'] = _callback
		@queue.PushRequest req

@msg_queue = new MessageQueue()
@mpd = new MpdService(@msg_queue)
@test = new TestModule(@msg_queue)


init = =>
	@socket.emit 'currentsong'
	@socket.emit 'status'
	
		
$('document').ready => 

