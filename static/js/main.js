// Generated by CoffeeScript 1.4.0
(function() {
  var init, on_current_song, on_status, parse_mpd_data, update,
    _this = this;

  this.socket = null;

  this.elapsed_time = 1;

  this.total_time = 1;

  init = function() {
    _this.socket.emit('currentsong');
    return _this.socket.emit('status');
  };

  update = function() {
    var elapsed_percent;
    elapsed_percent = _this.elapsed_time / _this.total_time * 100;
    _this.elapsed_time = _this.elapsed_time + 1;
    $('#elapsed-time').css('width', elapsed_percent + '%');
    return $('#total-time').css('width', (100 - elapsed_percent) + '%');
  };

  parse_mpd_data = function(data) {
    var list, parsed, splited, _fn, _i, _len;
    splited = data.split('\n');
    parsed = {};
    _fn = function(list) {
      var t;
      t = list.split(':');
      if (typeof t[1] === !String || t[1] === void 0) {
        return;
      }
      return parsed[t[0]] = t[1].substr(1);
    };
    for (_i = 0, _len = splited.length; _i < _len; _i++) {
      list = splited[_i];
      _fn(list);
    }
    return parsed;
  };

  on_current_song = function(data) {
    var parsed;
    parsed = parse_mpd_data(data);
    $('#artist').text(parsed.Artist);
    $('#title').text(parsed.Title);
    return _this.total_time = parseInt(parsed.Time);
  };

  on_status = function(data) {
    var parsed;
    parsed = parse_mpd_data(data);
    return _this.elapsed_time = parseInt(parsed.time);
  };

  $('document').ready(function() {
    _this.socket = io.connect(location.host);
    _this.socket.on('currentsong', on_current_song);
    _this.socket.on('status', on_status);
    init();
    setInterval(update, 1000);
    return setInterval(init, 3000);
  });

}).call(this);
