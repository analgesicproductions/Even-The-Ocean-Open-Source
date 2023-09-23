package entity.player;
import entity.MySprite;
import help.InputHandler;
import openfl.Assets;
import flixel.FlxObject;
import state.MyState;

/**
 * 'Even' in real life (not daydream sequences)
 * @author Melos Han-Tani 2013
 */

class RealPlayer extends MySprite
{

	private var input:InputHandler;
	private var C_WALK_VEL:Int = 60;
	private var C_WALK_INIT_VEL:Int = 30;
	private var C_WALK_ACCEL:Int = 60;
	
	public function new(_x:Float,_y:Float,_p:MyState) 
	{
		super(_x, _y, _p, "RealPlayer");
		
		myLoadGraphic(Assets.getBitmapData("assets/sprites/player/pat.png"), true, false, 32, 32);
		
		input = R.input;
		maxVelocity.x = C_WALK_VEL;
		acceleration.y = 200;
		width = 16;
		height = 24;
		offset.x = 8;
		offset.y = 8;
	}
	override public function preUpdate():Void 
	{
		
		
		_minslopebump = 0;
		FlxObject.separate(this, parent_state.tm_bg);
		FlxObject.separate(this, parent_state.tm_bg2);
		super.preUpdate();
	}
	private var is_paused:Bool = false;
	public function pause_toggle(on:Bool = false):Void {
		is_paused = on;
		if (is_paused) {
			velocity.x = velocity.y = 0;
			animation.paused = true;
		} else {
			animation.paused = false;
		}
	}
	override public function update(elapsed: Float):Void 
	{
		if (is_paused) {
			return;
		}
		
		if (input.right) {
			if (velocity.x <= 0) {
				velocity.x = C_WALK_INIT_VEL;
			}
			
			if (isTouching(FlxObject.LEFT) && isTouching(FlxObject.DOWN)) {
				velocity.y = 30;
			} 
			acceleration.x = C_WALK_ACCEL;
		} else if (input.left) {
			if (velocity.x >= 0) {
				velocity.x = -C_WALK_INIT_VEL;
			}
			
			if (isTouching(FlxObject.RIGHT) && isTouching(FlxObject.DOWN)) {
				velocity.y = 30;
			} 
			acceleration.x = -C_WALK_ACCEL;
		} else {
			velocity.x = 0;
			acceleration.x = 0;
		}
		super.update(elapsed);
	}
	
	override public function postUpdate(elapsed):Void 
	{
		if (is_paused) {
			return;
		}
		super.postUpdate(elapsed);
	}
	
}