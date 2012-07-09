var net = require("net");
var carrier = require("carrier");

var connections = [];

var broadcastMessage = function (message) {
	for (var i = 0; i < connections.length; i++) {
		connections[i].write(message);
	}
};

var server = net.createServer(function (connection) {
	var username;
	
	connections.push(connection);	
	connection.setEncoding("utf8");
	
	carrier.carry(connection, function (line) {
		var message;
	
		if (!username) {
			username = line;
			message = ":" + username + " joined the chat";
		} else {
			message = username + ":" + line;
		}
		
		broadcastMessage(message);
	});
	
	connection.on("close", function () {				
		var index = connections.indexOf(connection);
		if (index >= 0) {
			connections.splice(index, 1);
		}
		
		broadcastMessage(":" + username + " left the chat");
	});
});

server.listen(4000);