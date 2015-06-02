package as3{
	import flash.display.MovieClip;
	
	public class GameState extends MovieClip{
		
		public var gsm:GameStateManager;
		
		public function GameState(gsm:GameStateManager){
			this.gsm = gsm;
		}
			
		public function Update():void{
			
		}
	}
}
