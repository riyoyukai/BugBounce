package as3{
	
	import flash.display.MovieClip;
	import flash.utils.*;
	
	public class Bug extends MovieClip{
		
		var bugType:int; // 1 is least valuable, 2 is mid, 3 is most
		
		var periodX:Number;
		var amplitudeX:Number;
		var periodY:Number;
		var amplitudeY:Number;
		public var aabb:Rect;
		var baseX:Number, baseY:Number;

		public function Bug(bugType){
			this.bugType = bugType;
			gotoAndStop(bugType);
		}

		public function Auto(){
			aabb = new Rect(x, y);

			ChooseBug(Random.ChooseOne([1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 3]));

			amplitudeX = Random.Range(Config.amplitudeMin, Config.amplitudeMax);
			periodX = Random.Range(Config.periodMin, Config.periodMax);
			amplitudeY = Random.Range(Config.amplitudeMin, Config.amplitudeMax);
			periodY = Random.Range(Config.periodMin, Config.periodMax);
			x = Random.Range(115, Config.StageWidth-115);
			baseX = x;
			baseY = y;
		}

		function ChooseBug(type:int):void{
			bugType = type;
			gotoAndStop(type);
			switch(type){
				case 1:
				this.y = Config.Height1;
				aabb.halfW = 40;
				aabb.halfH = 18;
				//score, positioning, etc
				break;
				
				case 2:
				this.y = Config.Height2;
				aabb.halfW = 51;
				aabb.halfH = 24;
				//score, positioning, etc
				break;
				
				case 3:
				this.y = Config.Height3;
				aabb.halfW = 50;
				aabb.halfH = 22;
				//score, positioning, etc
				break;
			}
		}

		function Update(){
			this.x = baseX + amplitudeX * Math.sin(GSInstructions.timeElapsed*10/periodX);
			this.y = baseY + amplitudeY * Math.cos(GSInstructions.timeElapsed*10/periodY);
						
			aabb.Update(x, y);
		}
	}
}
