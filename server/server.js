var app = require('http').createServer(handler)
  , io = require('socket.io').listen(app)
  , fs = require('fs')

app.listen(3000);

function handler (req, res) {
  fs.readFile(__dirname + '/index.html',
  function (err, data) {
    if (err) {
      res.writeHead(500);
      return res.end('Error loading index.html');
    }

    res.writeHead(200);
    res.end(data);
  });
}

// userlist
var users={};
io.sockets.on('connection', function (socket) {
  socket.emit('connected', {"greeting":"Welcome","id":new Date().getTime()});
  socket.on('login',function(data){
	  users[data.id] = 'on';
  });
  socket.on('exit',function(data){
	  users[data.id] = 'off';
  })
  socket.on('message', function (data) {
	  socket.broadcast.emit("message",data);
  });
});