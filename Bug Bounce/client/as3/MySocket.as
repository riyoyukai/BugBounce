package as3 {
	
	import flash.display.MovieClip;
	import flash.events.*;
	import flash.net.Socket;
	
	public class MySocket extends Socket {

		var buffer:String = "";
		public static var terminator:String = "\n";
		
		public function MySocket() {
			addEventListener(ProgressEvent.SOCKET_DATA, HandleData);
		}

		function HandleData(e:ProgressEvent):void {
			buffer += readUTFBytes(bytesAvailable);
			var messages:Array = buffer.split(terminator);
			buffer = messages.pop();
			
			for(var i = 0; i < messages.length; i++){
				var myEvent:DataEvent = new DataEvent(DataEvent.DATA, true, false, messages[i]);
				dispatchEvent(myEvent);
			}
		}
		
		public function SendMessage(json:String):void{ // should receive stringified object
			if(!this.connected){
				trace("Not connected");
				return;
			}
			
			this.writeUTFBytes(json + terminator);
			this.flush();
		}
		
		public function SendInput():void{
			var str:String = JSON.stringify(Keys.keys);
			SendMessage(str);
		}
		
		public function SendName(nm:String):void{
			SendMessage(JSON.stringify({
				t:"N",
				n:nm
			}));
		}
		
		public function SendQuit():void{
			close();
		}
		
		public function SendReady(num:int, nm:String, ready:Boolean):void{
			var readynum:int;
			if(ready) readynum = 1;
			else readynum = 0;
			SendMessage(JSON.stringify({
				t:"R",
				id:num,
				n:nm,
				r:readynum
			}));
		}
		
		public function SendSit(num:int, nm:String, sit:Boolean):void{
			var sitnum:int;
			if(sit) sitnum = 1;
			else sitnum = 0;
			SendMessage(JSON.stringify({
			   t:"S",
			   id:num,
			   n:nm,
			   s:sitnum
			}));
		}
	}
}
