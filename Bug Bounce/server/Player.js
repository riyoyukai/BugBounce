var AABB = require("./AABB.js").AABB;
var Config = require("./Config.js").Config;

var config = new Config();

exports.Player = function Player(id, nm, client){
	this.id = id;
	this.nm = nm;
	this.socket = client;

	// team # (1 or 2)
	this.team;

	// keyboard input information
	this.keyL = false;
	this.keyR = false;
	this.keyJ = false;

	// velocity information
	this.speedX = 0;
	this.speedY = 860;
	this.maxSpeedX = 300;
	this.maxSpeedY = 760;
	this.a = 800; // acceleration constant for deltatime

	// bounding box for collision
	this.aabb;

	this.score = 0;
	this.place = 0;

	this.jump = false;
	this.jumpPrev = false;

	this.GetPosition = function(id, numPlayers){
		var px = (config.StageWidth/(numPlayers + 1)) * (id + 1);
		var py = config.Ground - config.RandomRange(20, 100);
		var pw = 125;
		var ph = 112;
		this.aabb = new AABB(px, py, pw, ph);
	}

	// jump if player hits the ground
	this.Jump = function(){
		if(this.keyJ && this.aabb.Bottom > config.Height1) this.MaxJump();
		else this.speedY = -this.maxSpeedY * (3/4);

		this.jump = true;
		// send jump message to client
	}

	this.MaxJump = function(){
		this.speedY = -this.maxSpeedY;
		this.jump = true;
	}

	this.Update = function(dt){
		this.jump = false;

		// HORIZONTAL MOVEMENT
		if(this.keyL){
			this.speedX -= dt * this.a;
		}else if(this.keyR){
			this.speedX += dt * this.a;
		}else{
			this.speedX *= .8;
		}

		//x speed clamping
		if(this.speedX > this.maxSpeedX) this.speedX = this.maxSpeedX;
		if(this.speedX < -this.maxSpeedX) this.speedX = -this.maxSpeedX;

		this.aabb.x += this.speedX * dt;
		// END HORIZONTAL MOVEMENT

		// VERTICAL MOVEMENT
		if(this.aabb.Bottom >= config.Ground){
			this.aabb.y = config.Ground - this.aabb.halfH;
			this.Jump();
			//console.log("Jump! y:" + this.aabb.y + ", yspeed: " + this.speedY);
		}
		this.speedY += dt * this.a;

		//y speed clamping
		if(this.speedY > this.maxSpeedY) this.speedY = this.maxSpeedY;
		if(this.speedY < -this.maxSpeedY) this.speedY = -this.maxSpeedY;

		this.aabb.y += this.speedY * dt;
		// END VERTICAL MOVEMENT

		this.aabb.Update();

		// Clamping to screen
		if(this.aabb.Left < config.StageLeft){
			this.aabb.x = this.aabb.halfW;
			this.speedX *= -1;
		}
		if(this.aabb.Right > config.StageRight){
			this.aabb.x = config.StageWidth - this.aabb.halfW;
			this.speedX *= -1;
		}
	}

	this.IsCollidingWith = function(other){ // simple overlap detection
		if(this.aabb.Right < other.aabb.Left) return false;
		if(this.aabb.Left > other.aabb.Right) return false;
		if(this.aabb.Bottom < other.aabb.Top) return false;
		if(this.aabb.Top > other.aabb.Bottom) return false;
		return true;
	}

	this.CalculateCollisions = function(other){ // for bouncing off players
		if(!this.IsCollidingWith(other)) return;

		var overlapB1 = other.aabb.Bottom - this.aabb.Top; // distance to move down; OVERLAP B
        var overlapT1 = other.aabb.Top - this.aabb.Bottom; // distance to move up; OVERLAP T
        var overlapR1 = other.aabb.Right - this.aabb.Left; // distance to move Right; OVERLAP R
        var overlapL1 = other.aabb.Left - this.aabb.Right; // distance to move Left; OVERLAP L

        var overlapB = Math.abs(overlapB1);
        var overlapT = Math.abs(overlapT1);
        var overlapR = Math.abs(overlapR1);
        var overlapL = Math.abs(overlapL1);

        // find solution
        if (overlapT <= overlapB && overlapT <= overlapR && overlapT <= overlapL) {
			// you jumped on someone
			this.MaxJump(); // jump to the third tier!
        }
        else if (overlapB <= overlapT && overlapB <= overlapR && overlapB <= overlapL) {
			// you got jumped on
			if(this.speedY < 0) this.speedY *= -1; // send you back towards the ground
        }
        else if (overlapL <= overlapT && overlapL <= overlapR && overlapL <= overlapB) {
			// your right side collided
			this.speedX *= -1;// speeds should average and transfer i think, not just invert
			
			// this prevents them from sticking together...
			this.aabb.x -= 3;
			other.aabb.x += 3;
        }
        else if (overlapR <= overlapT && overlapR <= overlapB && overlapR <= overlapL) {
			// your left side collided
			this.speedX *= -1; // speeds should average and transfer i think, not just invert
			
			// this prevents them from sticking together...
			this.aabb.x += 3;
			other.aabb.x -= 3;
        }
	}
};