package as3 {
	
	import flash.events.*;
	
	public class GSGameOver extends GameState {

		var players:Array = new Array();
		var winners:Array = new Array();
		var numPlayers:int = 0;

		static var scoreY:Number = 570;

		static var place1x:Number = 434;
		static var place1y:Number = 338.85;

		static var place2x:Number = 589.95;
		static var place2y:Number = 391.6;

		static var place3x:Number = 278.05;
		static var place3y:Number = 440.8;

		static var place4x:Number = 745.9;
		static var place4y:Number = 497.6;
		
		public function GSGameOver(gsm:GameStateManager, p:Array) {
			super(gsm);

			this.players = p;
			
			if(stage) Init();
			else addEventListener(Event.ADDED_TO_STAGE, Init);
			
			bttnAgain.addEventListener(MouseEvent.CLICK, againFunction);
			bttnLeave.addEventListener(MouseEvent.CLICK, leaveFunction);
		}
		
		public function Init(e:Event = null):void{
			removeEventListener(Event.ADDED_TO_STAGE, Init);
			
			//stage.stageFocusRect = false;
			//stage.focus = this;

			for(var i:int = 0; i < players.length; i++){
				if(players[i] != null){
					numPlayers++;
					players[i].GoToIdle();
					players[i].score.y = scoreY;
					addChild(players[i]);
					addChild(players[i].score);
					SortWinners(players[i]);
				}
			}

			for(var i:int = 0; i < winners.length; i++){
				switch(i){
					case 0:
					winners[0].x = place1x;
					winners[0].y = place1y;
					winners[0].score.x = place1x;
					//winnerText.text = winners[0].playerName + " wins!";
					break;
					case 1:
					winners[1].x = place2x;
					winners[1].y = place2y;
					winners[1].score.x = place2x;
					break;
					case 2:
					winners[2].x = place3x;
					winners[2].y = place3y;
					winners[2].score.x = place3x;
					break;
					case 3:
					winners[3].x = place4x;
					winners[3].y = place4y;
					winners[3].score.x = place4x;
					break;
				}
			}
		}

		private function SortWinners(pc:Player):void{
			if(winners.length == 0) winners.push(pc);
			else{
				for(var i:int = 0; i < winners.length; i++){
					if(pc.score.GetScore() > winners[i].score.GetScore()){
						winners.splice(i, 0, pc);
						return;
					}
				}
				winners.push(pc);
			}
		}
		
		public function againFunction(e:MouseEvent):void{
			gsm.SwitchToLobby();
		}
		
		public function leaveFunction(e:MouseEvent):void{
			Main.socket.SendQuit();
			gsm.SwitchToTitle();
		}
		
		public override function Update():void{
			
		}
	}
}
