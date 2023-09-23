package ;

import flixel.FlxGame;
import state.EmptyGameState;
import flixel.FlxState;
/**
 * ...
 * @author Copyright Melos Han-Tani, Developer of Analgesic Productions LLC, 2013 - ? , www.twitter.com/han_tani
 */
class EmptyProjectClass extends FlxGame
{

	public function new() 
	{		
		
		super(832, 432, EmptyGameState, 1, 60, 30);

		
	}
	
}