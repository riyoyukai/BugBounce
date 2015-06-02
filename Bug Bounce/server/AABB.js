exports.AABB = 
function AABB(x, y, w, h){
	this.x = x;
	this.y = y;
	this.halfW = w/2;
	this.halfH = h/2;
	this.Left;
	this.Right;
	this.Top;
	this.Bottom;

	this.Update = function(){ // movieclip registration is center
		this.Left = this.x - this.halfW;
		this.Right = this.x + this.halfW;
		this.Top = this.y - this.halfH;
		this.Bottom = this.y + this.halfH;
	};
}