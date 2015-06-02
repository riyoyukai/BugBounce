var AABB = require("./AABB.js").AABB;
var Config = require("./Config.js").Config;

var config = new Config();

exports.Bug = function Bug(){
	this.lifetime = 0;

	this.bugType;

	this.dispose = false;
	
	this.aabb = new AABB(0, 0, 0, 0);
	
	this.baseX;
	this.baseY;

	this.amplitudeX = config.RandomRange(config.amplitudeMin, config.amplitudeMax);
	this.periodX = config.RandomRange(config.periodMin, config.periodMax);
	this.amplitudeY = config.RandomRange(config.amplitudeMin, config.amplitudeMax);
	this.periodY = config.RandomRange(config.periodMin, config.periodMax);

	this.points;

	this.ChooseBug = function(type){
		this.bugType = type;
		this.aabb.x = config.RandomRange(60, config.StageWidth-60);

		switch(type){
			case 1:
			this.aabb.y = config.Height1;
			this.aabb.halfW = 40;
			this.aabb.halfH = 18;
			this.points = 1;
			break;
			
			case 2:
			this.aabb.y = config.Height2;
			this.aabb.halfW = 51;
			this.aabb.halfH = 24;
			this.points = 4;
			break;
			
			case 3:
			this.aabb.y = config.Height3;
			this.aabb.halfW = 50;
			this.aabb.halfH = 22;
			this.points = 10;
			break;
		}

		this.baseX = this.aabb.x;
		this.baseY = this.aabb.y;
	};

	this.Update = function(dt){
		this.lifetime+=dt * 10; // times 100?
		this.aabb.x = this.baseX + this.amplitudeX * Math.sin(this.lifetime/this.periodX);
		this.aabb.y = this.baseY + this.amplitudeY * Math.cos(this.lifetime/this.periodY);

		this.aabb.Update();
	};
};