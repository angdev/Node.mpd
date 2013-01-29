// Generated by CoffeeScript 1.4.0
(function() {
  var MessageQueue, MpdHelper, MpdService, SocketWrapper, TestModule, init,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    _this = this;

  SocketWrapper = (function() {

    function SocketWrapper() {
      this.Socket = __bind(this.Socket, this);

      this.RegisterListener = __bind(this.RegisterListener, this);
      this.socket = io.connect(location.host);
      console.log('socket connected.');
    }

    SocketWrapper.prototype.RegisterListener = function(type, listener) {
      return this.socket.on(type, listener);
    };

    SocketWrapper.prototype.Socket = function() {
      return this.socket;
    };

    return SocketWrapper;

  })();

  MessageQueue = (function() {

    function MessageQueue() {
      this._process = __bind(this._process, this);

      this._onMessage = __bind(this._onMessage, this);

      this._frontRequest = __bind(this._frontRequest, this);

      this._popRequest = __bind(this._popRequest, this);

      this.PushRequest = __bind(this.PushRequest, this);

      this.RegisterListener = __bind(this.RegisterListener, this);
      this.socket_wrap = new SocketWrapper();
      this.queue = [];
      this.type_callback_dict = {};
      console.log('RequestQueue Constructed');
      setInterval(this._process, 20);
    }

    MessageQueue.prototype.RegisterListener = function(type, callback) {
      this.socket_wrap.RegisterListener(type, this._onMessage);
      this.type_callback_dict[type] = callback;
      return console.log(type + ' listener registered.');
    };

    MessageQueue.prototype.PushRequest = function(req) {
      var handler;
      if (req === null) {
        return;
      }
      if (req.type === void 0 || req.data === void 0) {
        return;
      }
      handler = {};
      handler['req'] = req;
      handler['is_processing'] = false;
      handler['is_processed'] = false;
      return this.queue.push(handler);
    };

    MessageQueue.prototype._popRequest = function() {
      return this.queue.shift();
    };

    MessageQueue.prototype._frontRequest = function() {
      return this.queue[0];
    };

    MessageQueue.prototype._onMessage = function(data) {
      var handler, ret_arr;
      console.log('onMsg');
      handler = this._frontRequest();
      ret_arr = {};
      ret_arr['data'] = data;
      ret_arr['callback'] = handler.req.callback;
      this.type_callback_dict[handler.req.type](ret_arr);
      return handler.is_processed = true;
    };

    MessageQueue.prototype._process = function() {
      var handler;
      if (this.queue.length <= 0) {
        return;
      }
      if (this.socket === null) {
        return;
      }
      console.log('process');
      handler = this._frontRequest();
      if (!handler.is_processed) {
        if (!handler.is_processing) {
          this.socket_wrap.Socket().emit(handler.req.type, handler.req.data);
          return handler.is_processing = true;
        } else {

        }
      } else {
        return this._popRequest();
      }
    };

    return MessageQueue;

  })();

  MpdHelper = (function() {

    function MpdHelper() {
      this.ParseMpdData = __bind(this.ParseMpdData, this);

    }

    MpdHelper.prototype.ParseMpdData = function(data) {
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

    return MpdHelper;

  })();

  MpdService = (function() {

    function MpdService(msg_queue) {
      this._logPlaylist = __bind(this._logPlaylist, this);

      this._getPlaylist = __bind(this._getPlaylist, this);

      this._onMpd = __bind(this._onMpd, this);
      console.log('Mpd Service start');
      this.queue = msg_queue;
      msg_queue.RegisterListener("mpd", this._onMpd);
    }

    MpdService.prototype._onMpd = function(ret_arr) {
      return ret_arr.callback(ret_arr.data);
    };

    MpdService.prototype._getPlaylist = function(id) {
      var req;
      req = {};
      req['type'] = 'mpd';
      req['data'] = {
        cmd: 'playlistinfo',
        data: 'playlistinfo ' + id + ':' + (id + 1) + '\n'
      };
      req['callback'] = function(data) {
        var album, artist, helper, parsed, title;
        helper = new MpdHelper();
        parsed = helper.ParseMpdData(data.data);
        title = parsed.Title;
        artist = parsed.Artist;
        album = parsed.Album;
        return $("#song_list tbody").append('<tr><td>' + title + '</td><td>' + artist + '</td><td>' + album + '</td></tr>');
      };
      return this.queue.PushRequest(req);
    };

    MpdService.prototype._logPlaylist = function() {
      var req;
      req = {};
      req['type'] = 'mpd';
      req['data'] = {
        cmd: 'playlistinfo',
        data: 'playlistinfo 220:221\n'
      };
      req['callback'] = function(data) {};
      return this.queue.PushRequest(req);
    };

    return MpdService;

  })();

  TestModule = (function() {

    function TestModule(msg_queue) {
      this.__mpdTest = __bind(this.__mpdTest, this);
      console.log('TestModule Start');
      this.queue = msg_queue;
    }

    TestModule.prototype.__mpdTest = function(_cmd, _data, _callback) {
      var req;
      req = {};
      req['type'] = "mpd";
      req['data'] = {
        cmd: _cmd,
        data: _data
      };
      req['callback'] = _callback;
      return this.queue.PushRequest(req);
    };

    return TestModule;

  })();

  this.msg_queue = new MessageQueue();

  this.mpd = new MpdService(this.msg_queue);

  this.test = new TestModule(this.msg_queue);

  init = function() {
    _this.socket.emit('currentsong');
    return _this.socket.emit('status');
  };

  $('document').ready(function() {
    var i, _i, _results;
    _results = [];
    for (i = _i = 0; _i < 50; i = ++_i) {
      _results.push(mpd._getPlaylist(i));
    }
    return _results;
  });

}).call(this);
