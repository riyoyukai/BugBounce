package as3 {
	
	import flash.events.*;	
	
	public class GSPlay extends GameState {
		
		public var players:Array;
		var numPlayers:int = 0;
		public var bugs:Array = new Array();
		

		public function GSPlay(gsm:GameStateManager, players:Array) {
			super(gsm);

			this.players = players;
			
			if(stage) Init();
			else addEventListener(Event.ADDED_TO_STAGE, Init);
			
			for(var i:int = 0; i < players.length; i++){
				if(players[i] != null){
					addChild(players[i]);
					numPlayers++;
				}
			}

			var idOfValidPlayer:int = 0;
			for(var i:int = 0; i < players.length; i++){
				if(players[i] != null){
					idOfValidPlayer++;
					players[i].score = new Score(idOfValidPlayer, numPlayers, players[i].playerName);
					addChild(players[i].score);
				}
			}
		}
		
		public function Init(e:Event = null):void{
			removeEventListener(Event.ADDED_TO_STAGE, Init);
			
			stage.stageFocusRect = false;
			stage.focus = this;
		}

		public function HandleQuitData(id:int, n:String):void{
			players[id].GoToIdle();
			players[id].speedY = 0;
			players[id].y = Config.Ground;
			players[id] = null;
		}

		public function HandleTimer(seconds:int){
			var mins:int = seconds/60;
			var secs:int = seconds%60;
			var s:String = "" + secs;
			if(secs < 10) s = "0" + secs;
			timer.text = mins+":"+s;
		}

		public function HandlePlayerUpdate(id:int, x:Number, y:Number, sy:Number){
			if(players[id] == null) return;

			players[id].x = x;
			players[id].y = y;
			players[id].speedY = sy;
		}

		public function HandleNewBug(b:Bug){
			bugs.push(b);
			addChild(b);
		}

		public function HandleKillBug(id:int, pID:int, pScore:int){
			players[pID].score.SetScore(pScore);
			removeChild(bugs[id]);
			//add new particle effect at bugs[id] position
			bugs.splice(id, 1);
		}

		public function HandleBugUpdate(id:int, x:Number, y:Number){
			if(bugs[id] == null){
				return;
			}

			bugs[id].x = x;
			bugs[id].y = y;
		}

		public function HandleJump(id:int){
			players[id].Jump();
		}
		
		public override function Update():void{
			for(var i = 0; i < players.length; i++){
				if(players[i] != null) players[i].Update();
			}
		}
	}
}
