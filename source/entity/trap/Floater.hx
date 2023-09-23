package entity.trap;

/**
 * @author Copyright Melos Han-Tani, Developer of Analgesic Productions LLC, 2013 - ? , www.twitter.com/han_tani
 */
// Floating balls that regulate energy in the air. They store up a lot of energy and are agitated when jumped on.
import autom.SNDC;
import entity.MySprite;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.util.FlxAxes;
import haxe.Log;
import help.AnimImporter;
import help.HelpTilemap;
import help.HF;
import state.MyState;

class Floater extends MySprite
{

	public static var ACTIVE_Floaters:List<Floater>;
	
	private var stem:FlxSprite;
	public function new(_x:Float,_y:Float,_parent:MyState) 
	{
		stem = new FlxSprite();
		super(_x, _y, _parent, "Floater");
	}
	
	override public function change_visuals():Void 
	{
		
		// "stem"
		AnimImporter.loadGraphic_from_data_with_id(this, 32, 32, "Floater");
		AnimImporter.loadGraphic_from_data_with_id(stem, 32, 32, "Floater");
		animation.play("idle",true);
		stem.animation.play("stem", true);
		stem.width = stem.height = 16;
		switch (vistype) {
			default:
				
		}
		width = height = 16;
		offset.set(8,8);
	}
	
	override public function getDefaultProps():Map<String,Dynamic> 
	{
		var p:Map<String,Dynamic> = new Map<String,Dynamic>();
		p.set("vis-dmg", "0,0");
		p.set("rise_vel", 20);
		p.set("base_dmg", 15);
		p.set("launch_mul", 1.35);
		p.set("min_launch", -250);
		return p;
	}
	
	private var base_dmg:Int = 20;
	private var launch_mul:Float = 0;
	private var min_launch:Float = 0;
	override public function set_properties(p:Map<String,Dynamic>):Void 
	{
		immovable = true;
		HF.copy_props(p, props);
		dmgtype = Std.parseInt(props.get("vis-dmg").split(",")[1]);
		vistype = Std.parseInt(props.get("vis-dmg").split(",")[0]);
		base_dmg = props.get("base_dmg");
		min_launch = props.get("min_launch");
		launch_mul = props.get("launch_mul");
	
			
		
		change_visuals();
	}
	
	override public function destroy():Void 
	{
		ACTIVE_Floaters.remove(this);
		stem.destroy();
		super.destroy();
		
	}
	
	override public function preUpdate():Void 
	{
		immovable = false;
		FlxObject.separateY(this, parent_state.tm_bg);
		immovable = true;
		super.preUpdate();
	}
	private var boost_ticks:Int = 0;
	private var times_hit:Int = 0;
	override public function update(elapsed: Float):Void 
	{
		
		if (!did_init) {
			did_init = true;
			ACTIVE_Floaters.add(this);
		}
		//if (boost_ticks > 0) {
			//boost_ticks--;
		//}
		if (state == 0) { 
			//if (R.input.jpA1 && R.player.velocity.y > 30) {
				//boost_ticks = 10;
			//}
			
			if (times_hit > 0) {
				if (velocity.y <= 0) {
					acceleration.y = 0;
					velocity.y = -props.get("rise_vel");
					if (y - iy <= (times_hit - 1) * 24) {
						times_hit --;
					}
				}
			} else {
				if (velocity.y != 0) {
					velocity.y = 0;
					y = iy;
				}
			}
				
			if (velocity.y <= 0 && overlaps(R.player)) {
				R.player.force_no_var_jump = true;
					if (R.player.is_on_the_ground(true)) {
						//Log.trace("hi");
						//R.player.do_vert_push( -100);
						R.player.y --;
						R.player.last.y = R.player.y;
					}
				if (R.player.velocity.y > min_launch) {
					R.player.velocity.y = min_launch;
				}
				if (R.player.velocity.y < min_launch * launch_mul) {
					R.player.velocity.y = min_launch * launch_mul;
				}
				if (R.player.is_in_wall_mode()) {
					R.player.velocity.y *= 0.5;
				}
				
				if (R.player.y + R.player.height + 2*FlxG.elapsed*R.player.velocity.y <= this.y) {
					
					velocity.y = 96;
					acceleration.y = -192; // 0.5 sec = goes 24 pixels
					
					state = 1;
					animation.play("hit", true);
					no_motion_ticks = 4;
					R.player.skip_motion_ticks = 4;
					times_hit ++;
				}
			}
		} else if (state == 1) {
			
			for (f in ACTIVE_Floaters) {
				if (f!= this && overlaps(f)) {
					velocity.y = 0;
					acceleration.y = 0;
					state = 0;
				}
			}
			if (parent_state.tm_bg.getTileCollisionFlags(this.x, this.y + this.height + 1) != 0 || HF.array_contains(HelpTilemap.active_water,parent_state.tm_bg.getTileID(this.x,this.y+this.height+1))) {
				if (R.player.overlaps(this) == false) {
					velocity.y = 0;
					acceleration.y = 0;
					state = 0;
				}
			} else if (velocity.y <= 0) {
				velocity.y = 0;
				acceleration.y = 0;
				state = 0;
				
			}
			if (state == 0) {
				//animation.play("idle", true);
			}
		}
		super.update(elapsed);
	}
	private var no_motion_ticks:Int = 0;
	override public function postUpdate(elapsed):Void 
	{
		if (no_motion_ticks > 0) { 
			no_motion_ticks--;
			if (no_motion_ticks == 0) {
				if (times_hit == 1) {
					R.sound_manager.play(SNDC.floater);
					FlxG.camera.shake(0.01, 0.05, null, true, FlxAxes.Y);
				} else {
					R.sound_manager.play(SNDC.floater);
					FlxG.camera.shake(0.01, 0.05, null, true, FlxAxes.Y);
				}
			}
			return;
		}
		super.postUpdate(elapsed);
	}
	
	override public function draw():Void 
	{
		stem.move(ix+width/2-stem.width/2,iy+height/2-stem.height/2);
		stem.draw();
		
		
		var nrToDraw:Int = Std.int(((this.y + height / 2) - (stem.y + 8)) / 7);
		stem.y = y + height / 2 - stem.height / 2;
		stem.y -= nrToDraw * 7;
		for (i in 0...nrToDraw) {
			stem.draw();
			stem.y += 7;
		}
		
		super.draw();
	}
}