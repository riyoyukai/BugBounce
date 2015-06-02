package as3 {
	
	import flash.display.MovieClip;
	import flashx.textLayout.formats.Float;
	
	public class Score extends MovieClip{
		
		var nm:String;
		var score:int = 0;

		public function Score(id:int, numPlayers:int, nm:String){
			this.nm = nm;
			this.x = (Config.StageWidth/(numPlayers + 1)) * (id);
			this.y = 735;
			
			if(stage) Init();
			else addEventListener(Event.ADDED_TO_STAGE, Init);
		}
		
		public function Init(e:Event = null):void{
			removeEventListener(Event.ADDED_TO_STAGE, Init);

			nmText.text = nm;
		}

		public function SetScore(points:int):void{
			score = points;
			scoreText.text = "" + score;
		}

		public function GetScore():int{
			return score;
		}
	}
}
