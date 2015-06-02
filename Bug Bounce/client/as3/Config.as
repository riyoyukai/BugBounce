package as3 {
	
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.utils.Timer;
	
	public class Config {
		
		static var StageWidth:int = 1024;
		static var StageHeight:int = 768;
		static var StageLeft:int = 0;
		static var StageTop:int = 0;
		static var StageRight:int = 1024;
		static var Ground:int = 660;
		
		static var Height1:int = 500;
		static var Height2:int = 350;
		static var Height3:int = 200;
		
		//range for bug movement
		static var amplitudeMin:Number = 3;
		static var amplitudeMax:Number = 20;
		static var periodMin:Number = 10;
		static var periodMax:Number = 30;
		
		static var deltaTime:Number;
		static var timeElapsed:Number; //how much time has passed in milliseconds
		static var timeElapsedInSeconds:Number; //how much time has passed in seconds
		static var timer:Timer = new Timer(10);
	}
}
