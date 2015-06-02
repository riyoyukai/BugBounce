package as3 {
	
	public class Random {
		
		static function Range(minNum:Number, maxNum:Number):Number {
			return (Math.floor(Math.random() * (maxNum - minNum + 1)) + minNum);
		}
		
		static function ChooseOne(array:Array):int{
			return array[Random.Range(0, array.length-1)];	
		}
	}
}
