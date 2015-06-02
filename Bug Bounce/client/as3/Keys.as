package as3 {
	
	import flash.events.*;
	
	/***
	 * This static class keeps track of what relevant keys are being pressed.
	 ***/
	public class Keys {
		
		static var Left:Boolean = false;
		static var Right:Boolean = false;
		static var Jump:Boolean = false;
		
		public static var keys:Object = {
			t:"I",
			l:0,
			r:0,
			j:0
		}
		
		/***
	 	 * This method is called from the event listener function.
		 * The parameters are the KeyboardEvent from the listener, to get the keyCode,
		 * and a boolean which is True if it's a KEY_DOWN event and False for KEY_UP
	 	 ***/
		static function KeyPressed(e:KeyboardEvent, b:Boolean):void{
			var bint:int;
			if(b) bint = 1;
			else bint = 0;
			switch(e.keyCode){
				case 37: case 65: // left arrow, a
				keys.l = bint;
				break;
				
				case 39: case 68: // right arrow, d
				keys.r = bint;
				break;
				
				case 32: // space
				keys.j = bint;
				break;
			}
		}
	}
}
