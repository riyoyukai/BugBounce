package as3 {
	
  	import flash.display.StageScaleMode;
	import flash.display.MovieClip;
	import flash.events.*;
	import flash.net.Socket;
	
	public class Main extends MovieClip {
		
		var gsm:GameStateManager;
		
		public static var socket:MySocket = new MySocket();
		
		public function Main() {
			if(stage) Init();
			else addEventListener(Event.ADDED_TO_STAGE, Init);
			
			addEventListener(Event.ENTER_FRAME, Update);
			
			socket.addEventListener(Event.CONNECT, HandleConnect);
			socket.addEventListener(IOErrorEvent.IO_ERROR, HandleError);
			socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, HandleError);
			socket.addEventListener(DataEvent.DATA, HandleData);
			
			gsm = new GameStateManager();
			addChild(gsm);
		}
		
		public function Update(e:Event){
			gsm.Update();
		}
		
		public function Init(e:Event = null):void{
			removeEventListener(Event.ADDED_TO_STAGE, Init);
			stage.scaleMode = StageScaleMode.NO_SCALE;
		}
		
		
		
		
		function HandleConnect(e:Event):void{
			trace("Connected!");
			gsm.SwitchToLobby();
		}
		function HandleError(e:ErrorEvent):void{
			trace(e.toString());
		}
		function HandleData(e:DataEvent):void{
			var msg:Object = null;
			
			try{
				//trace("Data: " + e.data);
				msg = JSON.parse(e.data);
			}catch(e:Error){
				trace("Malformed data packet; couldn't parse");
				trace("ERROR: " + e.toString());
				return;
			}
			
			if(msg == null) return;
			if(!msg.hasOwnProperty("t")) return; // if message doesn't have a 'type' property
			
			gsm.HandleData(msg);
		}
	}
}
