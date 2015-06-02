package as3 {
	
	import flash.display.MovieClip;
	import flash.utils.*;
	import flash.events.*;
	
	public class GSInstructions extends GameState {
		var time:int = 0;
		public static var timeElapsed:Number = 0;

		var maxJump:Boolean = false;
		var canMaxJump:Boolean = false;
		var moveL:Boolean = false;
		var moveR:Boolean = false;
		var spawnBugs:Boolean = false;
		
		var player:Player = new Player(0, "");
		var speedX:Number = 0;
		var maxSpeedX:Number = 300;
		var maxSpeedY:Number = 760;
		var a:Number = 800; // acceleration constant for deltatime

		var spawnCountdown:Number = 2;
		var spawnCountdownMax:Number = 2;
		public var bugs:Array = new Array();

		var page:int = 0;
		
		public function GSInstructions(gsm:GameStateManager) {
			super(gsm);
			
			if(stage) Init();
			else addEventListener(Event.ADDED_TO_STAGE, Init);
		}	
			
		public function Init(e:Event = null):void{
			removeEventListener(Event.ADDED_TO_STAGE, Init);
			addChild(player);
			player.x = Config.StageWidth/2;

			bttnNext.addEventListener(MouseEvent.CLICK, HandleNext);
			bttnBack.addEventListener(MouseEvent.CLICK, HandleBack);
			spacebar.visible = false;
			arrowkeys.visible = false;
		}
		
		public override function Update():void{	
			var timeNew:int = getTimer();
			var dt:Number = (timeNew - time)/1000;
			time = timeNew;

			timeElapsed += dt;
			spawnCountdown-=dt;
			if(spawnBugs && spawnCountdown <= 0 && bugs.length < 25){
				spawnCountdown = spawnCountdownMax;
				var b:Bug = new Bug(1);
				b.Auto();
				addChild(b);
				bugs.push(b);
			}

			if(moveL || moveR){
				if(moveL) speedX -= dt * this.a;
				if(moveR) speedX += dt * this.a;

				if(speedX > maxSpeedX) speedX = maxSpeedX;
				if(speedX < -maxSpeedX) speedX = -maxSpeedX;

				player.x += speedX * dt;

				if(player.x < 115){
					speedX *= -1;
					moveL = !moveL;
					moveR = !moveR;
					player.x += 20;
				}
				if(player.x > Config.StageWidth-115){
					speedX *= -1;
					moveL = !moveL;
					moveR = !moveR;
					player.x -= 20;
				}
			}
			
			if(player.y + player.height/2 >= 650){
				player.y = 650 - player.height/2;

				if(canMaxJump && Random.Range(0, 2) == 1) maxJump = !maxJump;

				if(maxJump)	player.speedY = -maxSpeedY;
				else player.speedY = -maxSpeedY * (3/4);
				player.Jump();
			}
			player.speedY += dt * this.a;
	
			if(player.speedY > maxSpeedY) player.speedY = maxSpeedY;
			if(player.speedY < -maxSpeedY) player.speedY = -maxSpeedY;
	
			player.y += player.speedY * dt;



			player.Update();
			for(var i:int = bugs.length-1; i >= 0; i--){
				bugs[i].Update();
				if(IsCollidingWith(player, bugs[i])){
					removeChild(bugs[i]);
					bugs.splice(i, 1);
				}
			}
		}

		public function IsCollidingWith(p:Player, b:Bug){
			var pRight:Number, pLeft:Number, pTop:Number, pBottom:Number;

			pLeft = player.x - 100/2;
			pRight = player.x + 100/2;
			pTop = player.y - 100/2;
			pBottom = player.y + 100/2;

			if(pRight < b.aabb.Left) return false;
			if(pLeft > b.aabb.Right) return false;
			if(pBottom < b.aabb.Top) return false;
			if(pTop > b.aabb.Bottom) return false;
			return true;
		}
		
		public function HandleNext(e:MouseEvent):void{
			page++;
			switch(page){
				case 1:
				maxJump = true;
				alertText.text = "If you hold the spacebar, you will jump higher.";
				spacebar.visible = true;
				break;

				case 2:
				maxJump = true;
				alertText.text = "Jumping on another player will cause you to jump even higher!";
				spacebar.visible = true;
				break;

				case 3:
				maxJump = false;
				moveL = true;
				spacebar.visible = false;
				arrowkeys.visible = true;
				alertText.text = "Hold the arrow keys to move left and right.";
				break;

				case 4:
				maxJump = false;
				arrowkeys.visible = false;
				spawnBugs = true;
				canMaxJump = true;
				alertText.text = "Bugs will spawn periodically.\nRun into them to eat them.";
				break;

				case 5:
				alertText.text = "Flies are worth 1 point, ladybugs are worth 4 points,"
				alertText.appendText(" and dragonflies are worth 10 points.");
				break;

				case 6:
				alertText.text = "The more points a bug is worth, the rarer it is, and the higher it will fly.";
				break;

				case 7:
				alertText.text = "The player who has the most points when time runs out is the winner!";
				bttnNext.visible = false;
				break;
			}
		}
		
		public function HandleBack(e:MouseEvent):void{
			gsm.SwitchToTitle();
		}
	}
}
