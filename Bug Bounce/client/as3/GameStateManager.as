package as3 {
	
	import flash.display.MovieClip;
	import flash.events.*;
	
	public class GameStateManager extends MovieClip{
		
		var gsCurrent:GameState;
		public var playerName:String = "";
		public var ipaddress:String = "";
		public var port:String = "";

		public function GameStateManager() {			
			if(stage) Init();
			else addEventListener(Event.ADDED_TO_STAGE, Init);
			
			SwitchToTitle();
		}
		
		public function Init(e:Event = null):void{
			removeEventListener(Event.ADDED_TO_STAGE, Init);
		
			stage.addEventListener(KeyboardEvent.KEY_DOWN, KeyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, KeyUp);
			Main.socket.addEventListener(Event.CLOSE, HandleClose);
		
		}

		function HandleClose(e:Event):void{
			SwitchToJoin();
			if(gsCurrent is GSJoin){
				(gsCurrent as GSJoin).HandleError("Server closed.");
			}
		}
		
		public function KeyDown(e:KeyboardEvent):void{
			Keys.KeyPressed(e, true);
			if(gsCurrent is GSPlay){
				Main.socket.SendInput();
			}
		}
		
		public function KeyUp(e:KeyboardEvent):void{
			Keys.KeyPressed(e, false);
			if(gsCurrent is GSPlay){
				Main.socket.SendInput();
			}
		}
		
		public function HandleData(msg:Object){
			switch(msg.t){
				case "D": // refuses to let people join server while game is in progress
				Main.socket.close();
				SwitchToJoin();
				if(gsCurrent is GSJoin){
					(gsCurrent as GSJoin).HandleError("Sorry, game in progress." + 
						" Please wait for the current game to end.");
				}
				break;

				case "X": // refuses to let people join server if name is not unique
				Main.socket.close();
				SwitchToJoin();
				if(gsCurrent is GSJoin){
					(gsCurrent as GSJoin).HandleError("Sorry, a player already exists with that name." +
						" Please choose a different one.");
				}
				break;

				case "N": // alerts when other players join
				if(gsCurrent is GSLobby){
					(gsCurrent as GSLobby).HandleJoinData(msg.n);
				}
				break;

				case "L": // receives state of lobby upon joining
				if(gsCurrent is GSLobby){
					(gsCurrent as GSLobby).HandleLobbyData(msg);
				}
				break;

				case "Q": // player quit lobby or game in progress
					trace("Received Quit data");
					if(gsCurrent is GSLobby){
						(gsCurrent as GSLobby).HandleQuitData(msg.id, msg.n);
					}

					if(gsCurrent is GSPlay){
						trace("sending quit data to gsplay");
						(gsCurrent as GSPlay).HandleQuitData(msg.id, msg.n);
					}
				break;

				case "S": // gsLobby, players sit/stand
				if(gsCurrent is GSLobby){
					if(msg.s != null)
					(gsCurrent as GSLobby).HandleSitData(msg.id, msg.n, msg.s == 1);

					else if(msg.n == playerName)
					(gsCurrent as GSLobby).HandleOccupiedData();
				}
				break;
				
				case "R": // gsLobby, players un/ready
				//msg.id // where the player is sitting
				//msg.n // name of player who readied
				//msg.r // whether the player readied or unreadied
				//msg.s // 1 for ready to start, 0 for waiting for ready
				if(gsCurrent is GSLobby){
					if(msg.s == 1){
						SwitchToPlay((gsCurrent as GSLobby).players);
					}else{
						(gsCurrent as GSLobby).HandleReadyData(msg.id, msg.n, msg.r == 1);
					}
				}
				break;
				
				case "UP": // gsPlay, update players
				//players[msg.id].x = msg.x;
				//players[msg.id].y  = msg.y;
				//players[msg.id].speedY = msg.sy;
				if(gsCurrent is GSPlay){
					(gsCurrent as GSPlay).HandlePlayerUpdate(msg.id, msg.x, msg.y, msg.s);
				}
				break;
				
				case "UB": // gsPlay, update bugs
				if(gsCurrent is GSPlay){
					(gsCurrent as GSPlay).HandleBugUpdate(msg.id, msg.x, msg.y);
				}
				break;

				case "J": // gsPlay, player id jumped so update animation
				if(gsCurrent is GSPlay){
					(gsCurrent as GSPlay).HandleJump(msg.id);
				}
				break;
				
				case "T": // gsPlay, update timer
				if(gsCurrent is GSPlay){
					(gsCurrent as GSPlay).HandleTimer(msg.s);
				}
				break;
				
				case "B": // gsPlay, create new bug
				if(gsCurrent is GSPlay){
					(gsCurrent as GSPlay).HandleNewBug(new Bug(msg.id));
				}
				break;
				
				case "K": // gsPlay, kill bug/add score
				if(gsCurrent is GSPlay){
					(gsCurrent as GSPlay).HandleKillBug(msg.id, msg.p, msg.s);
				}
				break;
				
				case "G": // gsPlay, game over
				if(gsCurrent is GSPlay){
					SwitchToGameOver((gsCurrent as GSPlay).players);
				}
				break;
			}
		}
		
		public function Update():void{

			if(gsCurrent != null){
				gsCurrent.Update();
			}
		}

        public function SwitchToTitle():void {
			if(gsCurrent != null) removeChild(gsCurrent);
            gsCurrent = new GSTitle(this);
			addChild(gsCurrent);
        }

        public function SwitchToJoin():void {
			removeChild(gsCurrent);
            gsCurrent = new GSJoin(this);
			addChild(gsCurrent);
        }

        public function SwitchToLobby():void {
			removeChild(gsCurrent);
            gsCurrent = new GSLobby(this);
			addChild(gsCurrent);
        }

        public function SwitchToInstructions():void {
			removeChild(gsCurrent);
            gsCurrent = new GSInstructions(this);
			addChild(gsCurrent);
        }

        public function SwitchToPlay(p:Array):void {
			removeChild(gsCurrent);
            gsCurrent = new GSPlay(this, p);
			addChild(gsCurrent);
        }

        public function SwitchToGameOver(p:Array):void { // send player array
			removeChild(gsCurrent);
            gsCurrent = new GSGameOver(this, p);
			addChild(gsCurrent);
        }

        public function SwitchToCredits():void {
			removeChild(gsCurrent);
            gsCurrent = new GSCredits(this);
			addChild(gsCurrent);
        }
	}
}
