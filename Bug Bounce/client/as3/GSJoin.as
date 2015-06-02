package as3 {
	
	import flash.display.MovieClip;
	import flash.events.*;	
	import flash.system.Security;
	
	public class GSJoin extends GameState {
		
		var errorTimer:int = 0;
		var errorTimerMax:int = 24*8;
		
		public function GSJoin(gsm:GameStateManager) {
			super(gsm);
			
			if(stage) Init();
			else addEventListener(Event.ADDED_TO_STAGE, Init);
			
			bttnJoin.addEventListener(MouseEvent.CLICK, HandleJoin);
			bttnBack.addEventListener(MouseEvent.CLICK, HandleBack);
            Main.socket.addEventListener(IOErrorEvent.IO_ERROR, HandleIOError);
		}

		private function Init(e:Event = null):void{
			removeEventListener(Event.ADDED_TO_STAGE, Init);

			nameText.text = gsm.playerName;
			ipText.text = gsm.ipaddress;
			portText.text = gsm.port;

			trace(gsm.playerName);
			trace(gsm.ipaddress);
			trace(gsm.port);
		}

		public function HandleJoin(e:MouseEvent):void{
			errorText.text = "Attempting to connect...";
			errorTimer = errorTimerMax;
			
			var nm:String = nameText.text;
			var ipaddress:String = ipText.text;
			var port:int = int(portText.text);
			
			var errorString = "";
			
			if(nameText.text == ""){
				errorString += "Name field is blank. ";
			}
			if(ipText.text == ""){
				errorString += "IP Address field is blank. ";
			}
			if(portText.text == ""){
				errorString += "Port field is blank. ";
			}
			
			if(errorString == ""){
				try{
					gsm.playerName = nm;
					gsm.ipaddress = ipaddress;
					gsm.port = "" + port;
					Security.loadPolicyFile("xmlsocket://"+ipaddress+":1111");
					Main.socket.connect(ipaddress, port);
				}catch(e:Error){
					HandleError(e.toString());
				}
			}else{
				HandleError(errorString);
			}
		}
		
		function HandleIOError(e:IOErrorEvent):void{
			HandleError("Could not connect with the given IP and Port information.\n" + 
						"Verify that the server is running and that your input is correct.");
		}

		public function HandleError(s:String):void{
			errorTimer = errorTimerMax;
			errorText.text = "ERROR: " + s;
		}
		
		public function HandleBack(e:MouseEvent):void{
			gsm.SwitchToTitle();
		}
		
		public override function Update():void{
			if(errorTimer >= 0){
				errorTimer--;
			}
			if(errorTimer < 0){
				errorText.text = "";
			}
		}
	}
}
