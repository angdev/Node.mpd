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
		if req.type == undefined
			return
		if req.type == 'mpd' && req.data == undefined
			return
		if req.type == 'func' && req.func == undefined
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
		#console.log 'onMsg'
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
		
		#console.log 'process'
		
		handler = @_frontRequest()
		if !handler.is_processed
			if !handler.is_processing
				if handler.req.type == 'mpd'
					@socket_wrap.Socket().emit handler.req.type, handler.req.data
				else if handler.req.type == 'func'
					handler.req.func()
					handler.is_processed = true
				handler.is_processing = true
			else
				return
		else
			@_popRequest()
			
class MpdHelper
	ParseMpdData: (data) =>
		#console.log data
		splited = data.split '\n'
		parsed = {}
		for list in splited
			do (list) ->
				t = list.split ':'
				return if typeof t[1] is not String or t[1] is undefined
				parsed[t[0]] = t[1].substr(1)
		parsed

	
class MpdService
	constructor: (msg_queue) ->
		console.log 'Mpd Service start'
		@queue = msg_queue
		@helper = new MpdHelper()
		msg_queue.RegisterListener "mpd", @_onMpd
		
	Init: =>
		req = {}
		req['type'] = 'mpd'
		req['data'] = { cmd: 'status', data: 'status\n' }
		req['callback'] = (data) =>
			parsed = @helper.ParseMpdData(data.data)
			cid = parseInt(parsed.songid)
			for i in [cid-15..cid+15]
				_req = {}
				_req['type'] = 'mpd'
				_req['data'] = { cmd: 'playlistid', data: ('playlistid ' + i + '\n') }
				_req['callback'] = (data) =>
					@_addToTable(data)
				@queue.PushRequest _req
			req = {}
			req['type'] = 'func'
			req['func'] = =>
				$("tr[songid='" + cid + "']").css('background-color', '#abcdef') 
			@queue.PushRequest req		
		@queue.PushRequest req
		
	StartUpdate: =>
		setInterval(@_update, 1000)
		
	_onMpd: (ret_arr) =>
		ret_arr.callback(ret_arr.data)
		
	_update: =>
		console.log 'update'
		
	_getStatus: (callback) =>
		req = {}
		req['type'] = 'mpd'
		req['data'] = { cmd: 'status', data: 'status\n' }
		req['callback'] = callback
		@queue.PushRequest req
				
	_addToTable: (data) =>
		parsed = @helper.ParseMpdData(data.data)
		console.log parsed
		title = parsed.Title;
		artist = parsed.Artist;
		album = parsed.Album;
		$("#song_list tbody").append('<tr songid="' + parsed.Id + '"><td>' + title + '</td><td>' + artist + '</td><td>' + album + '</td></tr>')
		
			
	_requestPlaylist: (id) =>
		req = {}
		req['type'] = 'mpd'
		req['data'] = { cmd: 'playlistid', data: ('playlistid ' + id + '\n') }
		req['callback'] = (data) =>
			parsed = @helper.ParseMpdData(data.data)
			#console.log parsed
			title = parsed.Title;
			artist = parsed.Artist;
			album = parsed.Album;
			$("#song_list tbody").append('<tr songid="'+ parsed.Id +'"><td>' + title + '</td><td>' + artist + '</td><td>' + album + '</td></tr>')
		@queue.PushRequest req
		
	_logPlaylist: =>
		req = {}
		req['type'] = 'mpd'
		req['data'] = { cmd: 'playlistinfo', data: 'playlistinfo 220:221\n' }
		req['callback'] = (data) ->
			#console.log data.data
		@queue.PushRequest req
		
#end_dev

class TestModule
	constructor: (msg_queue) ->
		console.log 'TestModule Start'
		@queue = msg_queue
	
	mpd: (_cmd, _data, _callback) =>
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
	mpd.Init()
	mpd.StartUpdate()
	
