package as3 {
	
	public class Rect {
		
		public var x:Number, y:Number, halfW:Number, halfH:Number;
		public var Left:Number, Right:Number, Top:Number, Bottom:Number;

		public function Rect(x:Number, y:Number) {
			this.x = x;
			this.y = y;
		}
		
		public function Update(x:Number, y:Number):void{
			this.x = x;
			this.y = y;
			this.Left = x - halfW;
			this.Right = x + halfW;
			this.Top = y - halfH;
			this.Bottom = y + halfH;
		}
	}
}
