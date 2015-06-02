package as3 {
	
	import flash.display.MovieClip;
	import flash.events.*;	
	
	public class GSLobby extends GameState {
		
		public var players:Array = new Array(null, null, null, null);
		var sitting:Boolean = false;
		var buttons:Array = new Array();
		var nameTexts:Array = new Array();
		var place:int = -1;
		var ready:Boolean = false;
		var alerts:Array = new Array();
		
		public function GSLobby(gsm:GameStateManager) {
			super(gsm);

			Main.socket.SendName(gsm.playerName);
			
			buttons.push(bttnSit1, bttnSit2, bttnSit3, bttnSit4);
			
			nameTexts.push(name1, name2, name3, name4);
			
			bttnSit1.addEventListener(MouseEvent.CLICK, HandleSit1);
			bttnSit2.addEventListener(MouseEvent.CLICK, HandleSit2);
			bttnSit3.addEventListener(MouseEvent.CLICK, HandleSit3);
			bttnSit4.addEventListener(MouseEvent.CLICK, HandleSit4);
			bttnStand.addEventListener(MouseEvent.CLICK, HandleStand);
			
			bttnReady.addEventListener(MouseEvent.CLICK, HandleReady);
			bttnUnready.addEventListener(MouseEvent.CLICK, HandleReady);
			
			bttnBack.addEventListener(MouseEvent.CLICK, HandleBack);
			
			bttnStand.visible = false;
		}

		public function HandleLobbyData(msg:Object):void{
			HandleAlert("Player " + msg.n + " joined the game.");
			if(msg.s == 1){
			HandleSitData(msg.id, msg.n, msg.s == 1);
			}
			if(msg.r == 1){
			HandleReadyData(msg.id, msg.n, msg.r == 1);
			}
		}

		public function HandleJoinData(n:String):void{
			HandleAlert("Player " + n + " joined the game.");
		}

		public function HandleQuitData(id:int, n:String):void{
			HandleAlert("Player " + n + " left the game.");
			if(id == -1) return;
			players[id] = null;
			nameTexts[id].text = "";
			if(!sitting) buttons[id].visible = true;
		}

		public function HandleOccupiedData():void{
			HandleAlert("That seat is occupied.");
			place = -1;
			sitting = false;
			SetButtonsVisible(true);
		}

		public function HandleSitData(id:int, nm:String, s:Boolean):void{
			var st:String = " sat down to play.";
			if(!s){
				st = " stood up.";
				players[id] = null;
			}else{
				players[id] = new Player(id, nm);
			}

			if(nm == gsm.playerName){
				place = id;
				sitting = s;
				if(s){
					// you sat down
					players[id].you = true;
					buttons[id].visible = false;
					bttnStand.x = buttons[place].x;
					bttnStand.y = buttons[place].y;
					bttnReady.visible = true;
					SetButtonsVisible(false);
				}else{
					// you stood up
					place = -1;
					ready = false;
					bttnReady.visible = false;
					bttnUnready.visible = false;
					SetButtonsVisible(true);
				}
			}else{
				if(!s){
					if(!sitting) buttons[id].visible = true;
				}else{
					buttons[id].visible = false;
				}
			}

			HandleAlert("Player " + nm + st);

			if(!s) nm = "";
			nameTexts[id].text = nm;
		}

		public function HandleReadyData(id:int, nm:String, r:Boolean):void{
			var rdy:String = " is ready.";
			if(!r) rdy = " is not ready.";
			HandleAlert("Player " + nm + rdy);
		}
		
		public function HandleSit(sitPlace:int):void{
			Main.socket.SendSit(sitPlace, gsm.playerName, !sitting);
		}

		public function SetButtonsVisible(set:Boolean):void{
			// toggle visible on all sit buttons
			for(var i = 0; i < buttons.length; i++){
				if(players[i] == null) buttons[i].visible = set;
			}
			bttnStand.visible = !set;
		}
		
		public function HandleSit1(e:MouseEvent):void{
			HandleSit(0);
		}
		
		public function HandleSit2(e:MouseEvent):void{
			HandleSit(1);
		}
		
		public function HandleSit3(e:MouseEvent):void{
			HandleSit(2);
		}
		
		public function HandleSit4(e:MouseEvent):void{
			HandleSit(3);
		}
		
		public function HandleStand(e:MouseEvent):void{
			HandleSit(place);
		}
		
		public function HandleReady(e:MouseEvent):void{
			ready = !ready;
			bttnReady.visible = !bttnReady.visible;
			bttnUnready.visible = !bttnUnready.visible;
			Main.socket.SendReady(place, gsm.playerName, ready);
		}
		
		public function HandleBack(e:MouseEvent):void{ 
			Main.socket.SendQuit();
			gsm.SwitchToTitle();
		}

		public function HandleAlert(s:String):void{
			alertText.text = "";

			alerts.push(s);
			if(alerts.length > 7){
				alerts = alerts.splice(1, 7);
			}

			for(var i = 0; i < alerts.length; i++){
				alertText.appendText(alerts[i]);
				if(i < alerts.length-1) alertText.appendText("\n");
			}
		}
	}
}
