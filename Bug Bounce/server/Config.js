exports.Config = function Config(){
	//constants
	this.StageWidth = 1024;
	this.StageHeight = 768;
	this.StageLeft = 0;
	this.StageTop = 0;
	this.StageRight = 1024;
	this.Ground = 700;
	
	//heights for bug spawn
	this.Height1 = 450;
	this.Height2 = 250;
	this.Height3 = 80;
	
	//range for bug movement - put in bug class?
	this.amplitudeMin = 3;
	this.amplitudeMax = 20;
	this.periodMin = 10;
	this.periodMax = 30;

	this.RandomRange = function(min, max){
		return (Math.floor(Math.random() * (max - min + 1)) + min);
	};

	this.ChooseOne = function(array){
		return array[this.RandomRange(0, array.length-1)];	
	};
};