// Generated by CoffeeScript 1.4.0
(function() {
  var OnConnection, socket_init;

  OnConnection = function(socket) {
    return console.log('socket.io connected');
  };

  socket_init = function(sockio) {
    return sockio.sockets.on('connection', OnConnection);
  };

  exports.socket_init = socket_init;

}).call(this);
