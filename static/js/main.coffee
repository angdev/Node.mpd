@socket = null
@elapsed_time = 1
@total_time = 1

init = =>
	@socket.emit 'currentsong'
	@socket.emit 'status'

update = =>
	elapsed_percent = @elapsed_time / @total_time * 100
	@elapsed_time = @elapsed_time + 1
	if @total_time < @elapsed_time
		init()
	$('#elapsed-time').css('width', elapsed_percent + '%')
	$('#total-time').css('width', (100 - elapsed_percent) + '%')

parse_mpd_data = (data) ->
	splited = data.split '\n'
	parsed = {}
	for list in splited
		do (list) ->
			t = list.split ':'
			return if typeof t[1] is not String or t[1] is undefined
			parsed[t[0]] = t[1].substr(1)
	parsed

on_current_song = (data) =>
	parsed = parse_mpd_data data
	$('#artist').text parsed.Artist
	$('#title').text parsed.Title
	@total_time = parseInt parsed.Time
	
on_status = (data) =>
	parsed = parse_mpd_data data
	@elapsed_time = parseInt parsed.time

$('document').ready => 

	@socket = io.connect location.host
	@socket.on 'currentsong', on_current_song
	@socket.on 'status', on_status

	init()
	setInterval update, 1000