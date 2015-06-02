package as3 {
	
	import flash.display.MovieClip;
	
	
	public class PlayerIdle extends MovieClip {
		
		
		public function PlayerIdle() {
			gotoAndPlay(Random.Range(0, 30));
		}
	}
	
}
