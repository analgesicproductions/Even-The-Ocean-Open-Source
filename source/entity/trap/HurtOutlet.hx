package entity.trap;
import autom.SNDC;
import entity.MySprite;
import flash.display.Bitmap;
import flixel.addons.tile.FlxTilemapExt;
import flixel.FlxObject;
import help.AnimImporter;
import help.FlxX;
import help.HF;
import flixel.FlxG;
import flixel.FlxSprite;
import state.MyState;
/**
 * @author Copyright Melos Han-Tani, Developer of Analgesic Productions LLC, 2013 - ? , www.twitter.com/han_tani
 */
class HurtOutlet extends MySprite
{

	public static var ACTIVE_HurtOutlets:List<HurtOutlet>;
	private var spark1:FlxSprite;
	private var spark2:FlxSprite;
	private var vis_spark_u:FlxSprite;
	private var vis_spark_r:FlxSprite;
	private var vis_spark_d:FlxSprite;
	private var vis_spark_l :FlxSprite;
	
	public function new(_x:Float,_y:Float,_parent:MyState) 
	{
		spark1 = new FlxSprite();
		spark2 = new FlxSprite();
		vis_spark_d = new FlxSprite();
		vis_spark_l = new FlxSprite();
		vis_spark_r = new FlxSprite();
		vis_spark_u = new FlxSprite();
		
		super(_x, _y, _parent, "HurtOutlet");
	
	}
	
	override public function change_visuals():Void 
	{
		
				spark1.makeGraphic(20, 16, 0x22ff0000);
				spark2.makeGraphic(16,20, 0x22ff0000);

		
		switch (vistype) {
			case 0: // dark
				AnimImporter.loadGraphic_from_data_with_id(this, 26, 26, name, "dark");
				dmgtype = 0;
				props.set("dmgtype", 0);
				vis_spark_d.makeGraphic(16, 2, 0xbbff00ff);
				vis_spark_u.makeGraphic(16, 2, 0xbbff00ff);
				vis_spark_r.makeGraphic(2, 16, 0xbbff00ff);
				vis_spark_l.makeGraphic(2, 16, 0xbbff00ff);
			case 1:
				AnimImporter.loadGraphic_from_data_with_id(this, 26, 26, name, "light");
				dmgtype = 1;
				props.set("dmgtype", 1);
				
				vis_spark_d.makeGraphic(16, 2, 0xbbffffff);
				vis_spark_u.makeGraphic(16, 2, 0xbbffffff);
				vis_spark_r.makeGraphic(2, 16, 0xbbffffff);
				vis_spark_l.makeGraphic(2, 16, 0xbbffffff);
			default:
				AnimImporter.loadGraphic_from_data_with_id(this, 26, 26, name, Std.string(vistype));
		}
		animation.play("off");
	}
	
	public function generic_circle_overlap(cx:Float,cy:Float,cr:Float,only_dmgtype:Int):Bool {
		
		if (mode != MODE_ON) {	
			return false;
		}
		if (t_off - tm_Off< -0.015) {
			return false;
		}
		
		if (FlxX.l1_norm_from_mid(this, R.player) > 48) {
			return false;
		}
		
		if (FlxX.circle_flx_obj_overlap(cx, cy, cr, spark1) || FlxX.circle_flx_obj_overlap(cx, cy, cr, spark2)) {
			
			if (only_dmgtype == 0 && dmgtype == 0) { 
				return true;
			} else if (only_dmgtype == 1 && dmgtype == 1) {
				return true;
			} 
		}
		return false;
	}
	public function generic_overlap(o:FlxObject,only_dmgtype:Int=-1):Bool {
		
		if (mode != MODE_ON) {	
			return false;
		}
	if (t_off < tm_Off) {
	return false;
	}
		
		
		

		if (overlaps_sparks(o)) {
			if (only_dmgtype == 0 && dmgtype == 0) { 
				return true;
			} else if (only_dmgtype == 1 && dmgtype == 1) {
				return true;
			} else if (only_dmgtype == -1) {
				return true;
			}
		}
		return false;
	}
	
	private var t_on:Float = 0;
	private var t_off:Float = 0;
	private var tm_On:Float = 0;
	private var tm_Off:Float = 0;
	private var mode:Int = 1;
	private var init_wait:Float = 0;
	private static inline var MODE_ON:Int = 0;
	private static inline var MODE_OFF:Int = 1;
	override public function getDefaultProps():Map<String,Dynamic> 
	{
		var p:Map<String,Dynamic> = new Map<String,Dynamic>();
		// Set default properties here
		p.set("vistype", 0);
		p.set("dmgtype", 0);
		p.set("dmg", 24);
		p.set("tm_on", 0.5);
		p.set("tm_off", 0.5);
		p.set("init_wait", 0);
		return p;
	}
	
	override public function set_properties(p:Map<String,Dynamic>):Void 
	{
		HF.copy_props(p, props);
		dmgtype = props.get("dmgtype");
		vistype = props.get("vistype");
		tm_Off = props.get("tm_off");
		tm_On = props.get("tm_on");
		init_wait = p.get("init_wait");
		change_visuals();
		vis_spark_l.visible = vis_spark_d.visible = vis_spark_r.visible = vis_spark_u.visible = false;
	}
	
	override public function destroy():Void 
	{
		
		ACTIVE_HurtOutlets.remove(this);
		//HF.remove_list_from_mysprite_layer(this, parent_state, [vis_spark_u,vis_spark_r,vis_spark_d,vis_spark_l,spark1,spark2]);
		super.destroy();
	}
	
	override public function update(elapsed: Float):Void 
	{
		//sparks.x = x - (sparks.width - width) / 2;
		//sparks.y = y - (sparks.height - height) / 2;
		x = ix  - 5;
		y = iy - 5;
		spark1.x = x + 3;
		spark1.y = y + 5;
		spark2.x = x + 5;
		spark2.y = y + 3;
		if (!did_init) {
			did_init = true;
			ACTIVE_HurtOutlets.add(this);
			//HF.add_list_to_mysprite_layer(this, parent_state, [vis_spark_u,vis_spark_r,vis_spark_d,vis_spark_l,spark1,spark2]);
		}
		
		if (init_wait > 0) {
			init_wait -= FlxG.elapsed;
			spark1.visible = spark2.visible = false;
			super.update(elapsed);
			return;
		}
		
		if (mode == MODE_OFF) {
			if (overlaps_sparks(R.player)) {
				mode = MODE_ON;
				R.sound_manager.play(SNDC.menu_move);
				animation.play("charge");	
			}
		} else if (mode == MODE_ON) {
			t_off += FlxG.elapsed;
			if (t_off > 0.5) {
				animation.play("on");
				t_off = 0;
				if (overlaps_sparks(R.player)) {
					R.player.skip_motion_ticks = 4;
					R.sound_manager.play(SNDC.OuchOutlet_Shock_Hit);
					if (dmgtype == 0) {
						R.player.add_dark(props.get("dmg"));
					} else if (dmgtype == 1) {
						R.player.add_light(props.get("dmg"));
					}
				}
				mode = 100;
			}
		} else if (mode == 100) {
			if (animation.finished) {
				mode = MODE_OFF;
				animation.play("off");
			}
		}
		
		super.update(elapsed);
	}
	private function overlaps_sparks(s:FlxObject):Bool {
		if (s.overlaps(spark1) || s.overlaps(spark2)) return true;
		return false;
	}
	override public function draw():Void 
	{
		if (mode == MODE_ON) {
			//vis_spark_l.move(ix - 2, iy);
			//vis_spark_r.move(ix +16, iy);
			//vis_spark_d.move(ix, iy+16);
			//vis_spark_u.move(ix, iy-2);
			var tm:FlxTilemapExt = parent_state.tm_bg;
			//if (tm.getTileCollisionFlags(ix - 2, iy + 2) == 0) {
				//vis_spark_l.draw();
			//}
			//if (tm.getTileCollisionFlags(ix + 16 + 2, iy + 2) == 0) {
				//vis_spark_r.draw();
			//}
			//if (tm.getTileCollisionFlags(ix + 2, iy + 16 + 2) == 0) {
				//vis_spark_d.draw();
			//}
			//if (tm.getTileCollisionFlags(ix + 2, iy - 2) == 0) {
				//vis_spark_u.draw();
			//}
		}
		super.draw();
	}
}