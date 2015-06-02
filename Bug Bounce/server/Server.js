var Bug = require("./Bug.js").Bug;
var Player = require("./Player.js").Player;
var Config = require("./Config.js").Config;

var config = new Config();

///////////////////////////////////////////// SERVER STUFF:

var port = 1234;

require("./policy.js");
var net = require("net");
var terminator = "\n";
var clients = [];
var numSitting = 0;
var numReady = 0;
var started = false;

var server = net.createServer(function(client){
	
	//if(clients.length == 4){
		// refuse more than 4 clients? nah spectating works fine
	//}
	clients.push(client);

	if(started){
		BroadcastGameInProgress(client);
	}else{
		client.id = -1;
		console.log("client connected ("+client.remoteAddress+"); there are now "+clients.length+" clients");

		var buffer = "";

		client.on('data', function(data){
			buffer += data;
			var messages = buffer.split(terminator);
			buffer = messages.pop();

			for(var i = 0; i < messages.length; i++){
				var msg;
				try{
					msg = JSON.parse(messages[i]);
				}catch(e){
					continue;
				}

				switch(msg.t){
					case "N": // receive player name
					if(client.nm == null){
						client.nm = msg.n;

						// check if client has same name as existing client
						var uniqueName = true;
						for(var i = 0; i < clients.length; i++){
							if(clients[i] == client) continue;
							if(client.nm == clients[i].nm) uniqueName = false;
						}
						if(uniqueName) BroadcastName(client, msg.n);
						else{
							BroadcastBadName(client);
							client.id = null;
						}
					}

					BroadcastLobby(client);
					break;

					case "Q": // player quit
					console.log(client.nm + " quit");
					BroadcastQuit(client.id, client.nm);
					break;

					case "S": // player sat or stood
					var occupied = false;
					var validSitStand = true;

					var st = "";
					if(msg.s == 1){ // player attempting to sit
						// first check if seat is occupied
						for(var i=0; i < clients.length; i++){
							if(clients[i].id == msg.id) occupied = true;
						}

						if(occupied){
							console.log("Player tried to sit in an occupied seat");
						}else{
							client.id = msg.id;
							client.sitting = true;
							st = " sat";
							numSitting++;
						}
					}else if(client.sitting){ // player attempted to stand
						client.id = -1;
						if(client.ready) numReady--;
						client.ready = false;
						client.sitting = false;
						st = " stood";
						numSitting--;
					}else validSitStand = false;

					if(validSitStand){
						if(!occupied){
							console.log("Player " + client.nm + st);
							BroadcastSit(msg.id, client.nm, msg.s);
						}else{
							BroadcastSit(-1, client.nm, null);
						}
					}

					break;

					case "R": // player readied or unreadied
					var rd = "";
					if(msg.r == 1){
						client.ready = true;
						rd = " is ready";
						numReady++;
						players[msg.id] = new Player(msg.id, msg.n, client);
						client.player = players[msg.id];
					}else{
						client.ready = false;
						rd = " is not ready";
						numReady--;
						players[msg.id] = null;
						client.player = null;
					}
					console.log("Player " + msg.n + rd);

					var rts = 0;
					if(clients.length >= 2 && numReady == numSitting || numReady == 4){
						rts = 1;
						console.log("Starting game...");
						started = true;
					}

					BroadcastReady(msg.id, msg.n, msg.r, rts);
					if(started) SetUpGame();
					break;

					case "I": // player input
					if(started && players[client.id] != null){
						players[client.id].keyL = (msg.l == 1);
						players[client.id].keyR = (msg.r == 1);
						players[client.id].keyJ = (msg.j == 1);
					}

					break;
				}
			}
		});
	}
	client.on('error', function(){});
	client.on('close', function(){
		var index = clients.indexOf(client);
		clients.splice(index, 1);
		
		if(client.id != null){
			console.log("Client disconnected; there are now "+clients.length+" clients.");
			if(client.sitting) numSitting --;
			if(client.ready) numReady --;
			BroadcastQuit(client.id, client.nm);

			if(clients.length == 0 && started){ // end game if all clients leave
				EndGame();
			}
			players[client.id] = null;
		}else{
			console.log("A client attempted to join, but was denied because the game is in progress or name was not unique.");
		}
	});



}).listen(port);


////////////////
var os=require('os');
var ifaces=os.networkInterfaces();
for (var dev in ifaces) {
  var alias=0;
  ifaces[dev].forEach(function(details){
    if (details.family=='IPv4') {
      console.log(dev+(alias?':'+alias:''),details.address);
      ++alias;
    }
  });
}

var address = server.address();
console.log("Server running on " + address.address + ":" + address.port);
////////////////

function Broadcast(json){
	json += terminator;
	for(var i = 0; i < clients.length; i++){
		clients[i].write(json);
	}
}

function BroadcastToClient(c, json){
	json += terminator;
	c.write(json);
}

function BroadcastExcludeClient(clientTo, json){
	json += terminator;
	for(var i = 0; i < clients.length; i++){
		if(clients[i] == clientTo) continue;
		clients[i].write(json);
	}
}

function BroadcastGameInProgress(clientTo){
	var data = {
		t:"D"
	};
	BroadcastToClient(clientTo, JSON.stringify(data));
}

function BroadcastBadName(clientTo){
	var data = {
		t:"X"
	};
	BroadcastToClient(clientTo, JSON.stringify(data));
}

function BroadcastLobby(clientTo){
	var datas = [];

	for(var i = 0; i < clients.length; i++){
		var c = clients[i];
		datas.push({
			t:"L",
			id:c.id,
			n:c.nm,
			s:c.sitting,
			r:c.ready
		});

	BroadcastToClient(clientTo, JSON.stringify(datas[i]));
	}
}

function BroadcastName(c, nm){
	var data = {
		t:"N",
		n:nm
	};
	BroadcastExcludeClient(c, JSON.stringify(data));
}

function BroadcastQuit(i, nm){
	var data = {
		t:"Q",
		id:i,
		n:nm
	};
	Broadcast(JSON.stringify(data));
}

function BroadcastSit(i, nm, sit){
	var data = {
		t:"S",
		id:i,
		n:nm,
		s:sit
	};
	Broadcast(JSON.stringify(data));
}

function BroadcastJump(i){
	var data = {
		t:"J",
		id:i
	};
	Broadcast(JSON.stringify(data));
}

function BroadcastBug(i){
	var data = {
		t:"B",
		id:i
	};
	Broadcast(JSON.stringify(data));
}

function BroadcastKillBug(bID, pID, pScore){
	var data = {
		t:"K",
		id:bID,
		p:pID,
		s:pScore
	};
	Broadcast(JSON.stringify(data));
}

function BroadcastTimer(seconds){
	var data = {
		t:"T",
		s:seconds
	};
	Broadcast(JSON.stringify(data));
}

function BroadcastReady(i, nm, rdy, rts){
	var data = {
		t:"R",
		id:i,
		n:nm,
		r:rdy,
		s:rts
	};
	Broadcast(JSON.stringify(data));
}

function BroadcastGameOver(){
	var data = {
		t:"G"
	};
	Broadcast(JSON.stringify(data));
}

function BroadcastUpdate(){
	var datas = [];
	for(var index = 0; index < players.length; index++){
		if(players[index] == null) continue;
		datas.push({
			t:"UP",
			id:index,
			x:players[index].aabb.x,
			y:players[index].aabb.y,
			s:players[index].speedY
		});
	}

	for(var index = 0; index < bugs.length; index++){
		datas.push({
			t:"UB",
			id:index,
			x:bugs[index].aabb.x,
			y:bugs[index].aabb.y
		});
	}

	for(var i = 0; i < datas.length; i++){
		Broadcast(JSON.stringify(datas[i]));
	}
}

///////////////////////////////////////////// GAME STUFF:
var players = [null, null, null, null];
var bugs = [];

var maxRoundTimer = 15;
var roundTimer = maxRoundTimer;
var lastSeconds = 10;
var spawnCountdown = 1.5;
var spawnCountdownMax = 1.5;

var timePrev = Date.now(); // in milliseconds

function GetDeltaTime(){
	var t = Date.now();
	var dt = (t - timePrev)/1000;
	timePrev = t;
	return dt;
}

function SetUpGame(){
	//server.close();
	var dt = GetDeltaTime();

	if(numReady == 3) spawnCountdownMax = 1.0;
	if(numReady == 4) spawnCountdownMax = .5;

	var idOfValidPlayer = 0;
	for(var i = 0; i < players.length; i++){
		if(players[i] == null) continue;
		players[i].GetPosition(idOfValidPlayer, numReady);
		idOfValidPlayer++;
	}

	BroadcastUpdate();

	GameLoop();
}

function EndGame(){
	BroadcastGameOver();

	started = false;

	bugs = [];
	roundTimer = maxRoundTimer;
	for(var i = 0; i < players.length; i++){
		players[i] = null;
		numReady = 0;
		numSitting = 0;
	}
	for(var i = 0; i < clients.length; i++){
		clients[i].id = -1;
		clients[i].sitting = false;
		clients[i].ready = false;
	}
}

function Timer(){
	newSeconds = Math.floor(roundTimer);

	if(newSeconds != lastSeconds){
		BroadcastTimer(newSeconds);
	}

	lastSeconds = newSeconds;
}

function GameLoop(){
	var dt = GetDeltaTime();
	roundTimer -= dt;

	if(roundTimer <= 0){
		EndGame();
	}else{
		Timer();

		// spawn bug
		spawnCountdown -= dt;
		if(spawnCountdown <= 0){
			var b = new Bug();
			b.ChooseBug(config.ChooseOne([1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 3]));
			bugs.push(b);
			BroadcastBug(b.bugType);
			spawnCountdown = spawnCountdownMax;
		}

		// update positions of all players
		for(var i = 0; i < players.length; i++){
			if(players[i] != null){
				players[i].Update(dt);
				if(players[i].jump) BroadcastJump(i);
			}
		}
		// update positions of all bugs
		for(var i = 0; i < bugs.length; i++){
			bugs[i].Update(dt);
		}

		// see if any players collided with any bugs
		for(var i = 0; i < players.length; i++){
			for(var j = bugs.length-1; j >= 0; j--){
				if(players[i] != null && players[i].IsCollidingWith(bugs[j])){
					players[i].score += bugs[j].points;
					BroadcastKillBug(j, i, players[i].score);
					bugs.splice(j, 1);
				}
			}

			// see if any players collided with each other
			for(var n = 0; n < players.length; n++){
				if(players[i] == null || players[n] == null){
					continue;
				}
				if(i == n){
					continue;
				}

				//console.log("Checking collisions... " + i + " against " + n);
				players[i].CalculateCollisions(players[n]);
			}
		}

		// fix bug overlap?

		BroadcastUpdate();

		if(clients.length > 0)
		setTimeout(GameLoop, 33);
	}
}