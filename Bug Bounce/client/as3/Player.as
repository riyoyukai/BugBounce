package as3 {
	
	import flash.display.MovieClip;
	import flash.events.*;
	
	public class Player extends MovieClip {
		// true when jump_intro is playing; false to indicate that jump_up should play
		var jumpIntroPlaying:Boolean = true;
		
		var JUMP_INTRO:int = 1;
		var JUMP_UP:int = 7;
		var JUMP_SWITCH:int = 8;
		var JUMP_FALL:int = 9;
		var IDLE:int = 10;
		var OFFSET:int = 10;
		
		var jumpThreshold:int = 70; // determines how long the 'JUMP_SWITCH' frame plays
		
		var index:int;
		public var playerName:String;
		public var speedY:Number = 0;
		public var you:Boolean = false;

		public var score:Score;
		
		public function Player(index:int, nm:String) {
			gotoAndPlay(2 + OFFSET * index);
			
			// player #, for which color frog to be
			this.index = index;
			this.playerName = nm;
			
			if(stage) Init();
			else addEventListener(Event.ADDED_TO_STAGE, Init);
		}
		
		public function Init(e:Event = null):void{
			removeEventListener(Event.ADDED_TO_STAGE, Init);
		}

		public function GoToIdle():void{
			gotoAndStop(IDLE + OFFSET * index);
		}
		
		public function Jump(){
			gotoAndPlay(JUMP_INTRO + OFFSET * index);
			jumpIntroPlaying = true;
		}
		
		public function Update():void{
			UpdateAnimations();
		}
				
		public function UpdateAnimations():void{
			if(jumpIntroPlaying && currentFrame == JUMP_UP + OFFSET * index){ // intro is done playing
				jumpIntroPlaying = false;
			}
			else if(speedY < -jumpThreshold && !jumpIntroPlaying){ // rising
				gotoAndStop(JUMP_UP + OFFSET * index);
			}
			else if(speedY > -jumpThreshold && speedY < jumpThreshold){ // switch frame
				gotoAndStop(JUMP_SWITCH + OFFSET * index);
			}
			else if(speedY > jumpThreshold){ // falling
				gotoAndStop(JUMP_FALL + OFFSET * index);
			}
		}
	}
}
