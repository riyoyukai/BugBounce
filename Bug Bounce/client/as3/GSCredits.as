package as3 {
	
	import flash.display.MovieClip;
	import flash.events.*;
	
	public class GSCredits extends GameState {
		
		public function GSCredits(gsm:GameStateManager) {
			super(gsm);
			
			bttnBack.addEventListener(MouseEvent.CLICK, HandleBack);
		}
		
		public override function Update():void{
			
		}
		
		public function HandleBack(e:MouseEvent):void{
			gsm.SwitchToTitle();
		}
	}
}
