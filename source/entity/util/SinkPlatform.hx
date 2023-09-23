package entity.util;
import entity.MySprite;
import flixel.FlxSprite;
import global.C;
import haxe.Log;
import help.AnimImporter;
import help.FlxX;
import help.HF;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.math.FlxPoint;
import state.MyState;

/**
 * @author Copyright Melos Han-Tani, Developer of Analgesic Productions LLC, 2013 - ? , www.twitter.com/han_tani
 */
class SinkPlatform extends MySprite
{

	private var stem:FlxSprite;
	public static var ACTIVE_SinkPlatforms:List<SinkPlatform>;
	public function new(_x:Float,_y:Float,_parent:MyState) 
	{
		
		stem = new FlxSprite();
		super(_x, _y, _parent, "SinkPlatform");
		immovable = true;
	}
	
	override public function change_visuals():Void 
	{
		switch (vistype) {
			default:
				AnimImporter.loadGraphic_from_data_with_id(this, 32,48, name);
				AnimImporter.loadGraphic_from_data_with_id(stem, 32, 48, name);
				stem.animation.play("stem");
				stem.width = stem.height = 16;
				//makeGraphic(32,48, 0xffff0000);
		}
	}
	public function my_recv_message(message_type:String,x:Float,y:Float,h:Float):Int 
	{
		if (message_type == C.MSGTYPE_STOP) {
			state = state_stopped;
			this.x = x; 
			this.y = y + h - this.height;
			return C.RECV_STATUS_OK;
		}
		return C.RECV_STATUS_NOGOOD;
	}
	override public function getDefaultProps():Map<String,Dynamic> 
	{
		var p:Map<String,Dynamic> = new Map<String,Dynamic>();
		p.set("xvel", 37);
		p.set("yvel", 30);
		p.set("returns_home", 1);
		p.set("return_rate", 14.5);
		return p;
	}
	
	override public function set_properties(p:Map<String,Dynamic>):Void 
	{
		HF.copy_props(p, props);
		change_visuals();
	}
	
	override public function destroy():Void 
	{
		
		ACTIVE_SinkPlatforms.remove(this);
		HF.remove_list_from_mysprite_layer(this, parent_state, [stem]);
		stem.destroy();
		super.destroy();
	}
	
	private var touchestmap:Bool = false;
	override public function preUpdate():Void 
	{
		//Log.trace([this.x, this.last.x]);
		immovable = false;
		if (FlxObject.separateX(this, parent_state.tm_bg) ||FlxObject.separateX(this, parent_state.tm_bg2) ) {
			touchestmap = true;
			//Log.trace("hi");
		}
		immovable = true;
		super.preUpdate();
	}
	private var state_stopped:Int = 3;
	override public function update(elapsed: Float):Void 
	{
		if (!did_init) {
			did_init = true;
			ACTIVE_SinkPlatforms.add(this);
			HF.insert_list_before_object_in_mysprite_layer(this, parent_state, [stem]);
		}
	
		if (state == 0) {
			velocity.y = 0;
			var touches:Bool  = false;
			if (FlxX.l1_norm_from_mid(this, R.player) < 60) {
				var oldallowcol:Int = R.player.allowCollisions;
				R.player.allowCollisions |= FlxObject.DOWN;
				touches = FlxObject.separate(R.player, this);
				R.player.allowCollisions = oldallowcol;
			}
			
			
				// dont push if on grund
				if (touches && (!R.input.left && !R.input.right) && (parent_state.tm_bg2.getTileCollisionFlags(R.player.x + 5, R.player.y + R.player.height + 2) != 0 || parent_state.tm_bg.getTileCollisionFlags(R.player.x + 5, R.player.y + R.player.height + 2) != 0)) {
					touches = false;
				}
			
			
			if (touches && R.player.touching & FlxObject.DOWN > 0) {
				
				//velocity.y = props.get("yvel");
				//R.player.velocity.y = props.get("yvel");
				R.player.extra_x = velocity.x * FlxG.elapsed;
				touches = false; 
			}
			
			if (touches) {
				if (R.player.touching & FlxObject.UP > 0) {
						
				} else if (R.player.touching & FlxObject.RIGHT > 0) {
					
					R.player.activate_wall_hang();
					state = 1;
					animation.play("open");
				} else if (R.player.touching & FlxObject.LEFT > 0) {
					R.player.activate_wall_hang();
					state = 2;
					animation.play("open");
				} 
			} else {
				// dont 'return home' through player
				
				
				if (props.get("returns_home") == 1 && !overlaps(R.player) && touching == 0) {
					if (x > ix) {
						velocity.x = -props.get("return_rate");
						if (x + FlxG.elapsed * velocity.x < ix) {
							x = ix;
							velocity.x = 0;
						}
					} else if (x < ix) {
						velocity.x = props.get("return_rate");
						if (x + FlxG.elapsed * velocity.x > ix) {
							x = ix;
							velocity.x = 0;
						}
					}
					
					if (y > iy) {
						velocity.y = -props.get("return_rate");
						if (y + FlxG.elapsed * velocity.y < iy) {
							velocity.y = 0;
							y = iy;
						}
					} else if (y < iy) {
						velocity.y = props.get("return_rate");
						if (y + FlxG.elapsed * velocity.y > iy) {
							velocity.y = 0;
							y = iy;
						}
					}
				} else {
					velocity.x = 0;
				}
			}
			
		} else if (state == 1){ 
			velocity.x = props.get("xvel");
			if (R.player.velocity.x <= -10 || (R.player.is_on_the_ground(true) && !R.input.left && !R.input.right) || !R.player.is_wall_hang_points_in_object(this)) {
				state = 0;
				
				animation.play("close");
				velocity.x = 0;
				touchestmap = false;
			R.player.x = x - R.player.width;
			} else { 	
				
			R.player.x = x - R.player.width + 1;
			R.player.activate_wall_hang();
			}
		} else if (state == 2) {
			velocity.x = -props.get("xvel");
			if (R.player.velocity.x >= 10  || (R.player.is_on_the_ground(true) && !R.input.left && !R.input.right) ||!R.player.is_wall_hang_points_in_object(this)) {
				state = 0;
				animation.play("close");
				velocity.x = 0;
				touchestmap = false;
			R.player.x = x + width;
			} else {
				
			R.player.x = x + width - 1;
			R.player.activate_wall_hang();
			}
		} else if (state == state_stopped) {
			velocity.x = velocity.y = 0;
		}
		
		if (touchestmap) {
			//Log.trace("hi2");
			velocity.x = 0;
		}
		super.update(elapsed);
	}
	
	override public function draw():Void 
	{
		stem.move(ix + width / 2 - (stem.width / 2), iy + height/2 - (stem.height/2));
		
		stem.draw();
		
		
		
		var d:Float = Math.abs((stem.x + stem.width / 2) - (x + width / 2));
		var nrToDraw:Int = Std.int((d) / 16);
		x += (width / 2 - stem.width / 2);
		y += (height / 2 - stem.height / 2);
		
		HF.scale_velocity(stem.velocity, stem, this, 16);
		stem.move(x, y);
		for (i in 0...nrToDraw) {
			stem.x -= stem.velocity.x;
			stem.y -= stem.velocity.y;
			stem.draw();
		}
		x -= (width / 2 - stem.width / 2);
		y -= (height / 2 - stem.height / 2);
		stem.velocity.set(0, 0);
		super.draw();
	}
}