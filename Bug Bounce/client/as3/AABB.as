package as3 {
	
	public class Rect {
		
		public var x:Number, y:Number, width:Number, height:Number;
		public var Left:Number, Right:Number, Top:Number, Bottom:Number;

		public function Rect(x:Number, y:Number, width:Number, height:Number) {
			this.x = x;
			this.y = y;
			this.width = width;
			this.height = height;
		}
		
		public function Update(x:Number, y:Number, width:Number, height:Number):void{
			this.x = x;
			this.y = y;
			this.width = width;
			this.height = height;
			this.Left = x;
			this.Right = x + width;
			this.Top = y;
			this.Bottom = y + height;
			//trace(x + ", " + y + ", " + width + ", " + height);
		}
	}
}
