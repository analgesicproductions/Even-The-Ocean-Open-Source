package entity.util;
import entity.enemy.GhostLight;
import entity.MySprite;
import entity.player.BubbleSpawner;
import flixel.math.FlxPoint;
import global.C;
import haxe.Log;
import help.AnimImporter;
import help.HF;
import state.MyState;

/**
 * ...
 * @author Copyright Melos Han-Tani, Developer of Analgesic Productions LLC, 2013 - ? , www.twitter.com/han_tani
 */
class BubbleSwitch extends MySprite
{

	public function new(_x:Float,_y:Float,_parent:MyState) 
	{
		super(_x, _y, _parent, "BubbleSwitch");
	}
	
	private var BEHAVIOR:Int  = 0;
	private var BEHAVIOR_BOTH:Int = 2;
	private var BEHAVIOR_DARK:Int = 0;
	private var BEHAVIOR_LIGHT:Int = 1;
	override public function change_visuals():Void 
	{
		animation.paused = true;
		if (ghost_on) {
			AnimImporter.loadGraphic_from_data_with_id(this, 32, 32, name, "ghost");
			animation.paused = false;
			if (vistype == 0) {
				animation.play("idle", true);
			} else {				
				animation.play("idle_l", true);
			}
			
		} else {
		switch (vistype) {
			case 0:
				BEHAVIOR = BEHAVIOR_DARK;
				AnimImporter.loadGraphic_from_data_with_id(this, 16, 16, name, "dark");
				animation.play("idle", true);
			case 1:
				BEHAVIOR = BEHAVIOR_LIGHT;
				AnimImporter.loadGraphic_from_data_with_id(this, 16, 16, name, "light");
				animation.play("idle", true);
			case 2:
				BEHAVIOR = BEHAVIOR_BOTH;
				AnimImporter.loadGraphic_from_data_with_id(this, 16, 16, name, "neutral");
				animation.play("idle", true);
			default: 
				AnimImporter.loadGraphic_from_data_with_id(this, 16, 16, name, Std.string(vistype));
				animation.play("idle", true);
				BEHAVIOR = props.get("behave_type");
		}
		height = 16;
		offset.y = 16;
		}
	}
	
	private var ghost_on:Bool = false;
	private var gs:Float = 0;
	private var gr:Float = 0;
	private var gmv:Float = 0;
	override public function getDefaultProps():Map<String,Dynamic> 
	{
		var p:Map<String,Dynamic> = new Map<String,Dynamic>();
		p.set("vistype", BEHAVIOR_BOTH);
		p.set("behave_type", BEHAVIOR_BOTH);
		p.set("children", "0");
		p.set("ghost_on", 0);
		p.set("ghost_maxvel", 150);
		p.set("ghost_pull_strength", 60);
		p.set("ghost_radius", 64);
		return p;
	}
	
	override public function set_properties(p:Map<String,Dynamic>):Void 
	{
		HF.copy_props(p, props);
		vistype = props.get("vistype");
		ghost_on = false;
		if (1 == props.get("ghost_on")) {
			ghost_on = true;
			gs = props.get("ghost_pull_strength");
			gr = props.get("ghost_radius");
			gmv = props.get("ghost_maxvel");
		}
		change_visuals();
	}
	
	override public function destroy():Void 
	{
		super.destroy();
	}
	
	override public function update(elapsed: Float):Void 
	{
		
		if (R.editor.editor_active || !did_init) {
			if (ghost_on) {
				angle = 0; offset.set(0, 0);
			} else {
			if (parent_state.tm_bg.getTileCollisionFlags(x, y - 16) == 0) {
				angle = 0;
				offset.set(0, 16);
			}
			if (parent_state.tm_bg.getTileCollisionFlags(x+16, y) == 0) {
				angle = 90;
				offset.set(-8, 8);
			}
			if (parent_state.tm_bg.getTileCollisionFlags(x, y+16) == 0) {
				angle = 180;
				offset.set(0, 0);
			}
			if (parent_state.tm_bg.getTileCollisionFlags(x - 16, y) == 0) {
				angle = 270;
				offset.set(8, 8);
			}
			}
		}
		
		
		
		if (!did_init) {
			did_init = true;
			pt = new FlxPoint();
			populate_parent_child_from_props();
		}
		
		if (ghost_on) {
			update_ghost();
			super.update(elapsed);
			return;
		} 
		
		if (BubbleSpawner.cur_bubble != null && BubbleSpawner.cur_bubble.visible == true) {
			if (BubbleSpawner.cur_bubble.overlaps(this)) {
				if (BEHAVIOR == BEHAVIOR_DARK && BubbleSpawner.cur_bubble_flavor == 0) {
					broadcast_to_children(C.MSGTYPE_ENERGIZE_TICK_DARK);
					BubbleSpawner.force_pop(1, this.x + this.width / 2, this.y + this.height / 2 );
				} else if (BEHAVIOR == BEHAVIOR_LIGHT && BubbleSpawner.cur_bubble_flavor == 1) {
					broadcast_to_children(C.MSGTYPE_ENERGIZE_TICK_LIGHT);
					BubbleSpawner.force_pop(1, this.x + this.width / 2, this.y + this.height / 2);
				} else if (BEHAVIOR == BEHAVIOR_BOTH) {
					if (BubbleSpawner.cur_bubble_flavor == BubbleSpawner.BUBBLE_DARK) {
						broadcast_to_children(C.MSGTYPE_ENERGIZE_TICK_DARK);
					} else {
						broadcast_to_children(C.MSGTYPE_ENERGIZE_TICK_LIGHT);
					}
					BubbleSpawner.force_pop(1, this.x + this.width / 2, this.y + this.height / 2); 
				}
				lasttouched = this;
			}
		}
		super.update(elapsed);
	}
	public static var lasttouched:BubbleSwitch;
	private var pt:FlxPoint;
	private function update_ghost():Void {
		width = gr * 2;
		height = gr * 2;
		x = (ix + 16) - gr;
		y = (iy + 16) - gr;
		for (g in GhostLight.ACTIVE_GhostLights) {
			if (g.is_ghost && g.mode != 6) {
					if (g.overlaps(this)) {
						x += width / 2;
						y += height / 2;
						g.x += g.width / 2;
						g.y += g.height / 2;
						HF.scale_velocity(pt, g, this, gmv);
						if (g.velocity.x < pt.x) {
							g.velocity.x += (1 / 60) * gs;
						} else {
							g.velocity.x -= (1 / 60) * gs;
						}
						if (g.velocity.y < pt.y) {
							g.velocity.y += (1 / 60) * gs;
						} else {
							g.velocity.y -= (1 / 60) * gs;
						}
						g.x -= g.width / 2;
						g.y -= g.height / 2;
						x -= width / 2;
						y -= height / 2;
					}
			
			}
		}
		width = 32;
		height = 32;
		
		
		x = ix;
		y = iy;
		
		
		for (g in GhostLight.ACTIVE_GhostLights) {
			if (g.is_ghost) {
				if (g.overlaps(this)) {
					if (g.mode == 6) {
						g.velocity.x *= 0.85;
						g.velocity.y *= 0.85;
						if (g.x < ix + 16- g.width/2) g.x += 1;
						if (g.x > ix + 16 - g.width/2) g.x -= 1;
						if (g.y > iy + 16 - g.height/2) g.y -= 1;
						if (g.y < iy + 16 - g.height/2) g.y += 1;
					} else {
						if (g.dmgtype == 1) {
							broadcast_to_children(C.MSGTYPE_ENERGIZE_LIGHT);
						} else {
							broadcast_to_children(C.MSGTYPE_ENERGIZE_DARK);
						}
						g.animation.play("off");
						g.mode = 6;
					}
				}
			}
		}
		
	}
	
	
}