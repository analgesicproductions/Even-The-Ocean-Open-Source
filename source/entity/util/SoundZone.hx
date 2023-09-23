package entity.util;

import autom.SNDC;
import entity.MySprite;
import entity.npc.GenericNPC;
import flixel.text.FlxBitmapText;
import flixel.FlxObject;
import flixel.math.FlxRect;
import global.C;
import haxe.Log;
import help.HF;
import state.MyState;
import help.AnimImporter;
import flixel.FlxG;
import flixel.FlxSprite;

class SoundZone extends MySprite
{

	private var drag_box:FlxSprite;
	private var trigger_box:FlxObject;
	public static var active_floor_sound:String = "player_jump_down.wav"; // always start as generic
	public static var active_wall_sound:String = "step_rock.wav";
	public static var default_floor_sound:String = "player_jump_down.wav"; // always start as generic
	public static var default_wall_sound:String = "step_rock.wav";
	
	private var cur_type_text:FlxBitmapText;
	
	public function new(_x:Float,_y:Float,_parent:MyState) 
	{
		drag_box = new FlxSprite();
		trigger_box = new FlxObject();
		super(_x, _y, _parent, "SoundZone");
	}
	
	override public function change_visuals():Void 
	{
		makeGraphic(16, 16, 0xffff00ff);
		alpha = 0.75;
		drag_box.makeGraphic(16, 16, 0xffff00ff);
		drag_box.alpha = 0.75;
	}
	
	public var trigger_w:Int = 0;
	public var trigger_h:Int = 0;
	private var type:String = "";
	private var wall_type:String = "";
	
	private var modify_mode:Int = 2;
	override public function getDefaultProps():Map<String,Dynamic> 
	{
		var p:Map<String,Dynamic> = new Map<String,Dynamic>();
		p.set("tile_w", 8);
		p.set("tile_h", 8);
		p.set("type", "generic");
		p.set("wall_type", "generic");
		p.set("revert_on_exit", 0);
		return p;
	}
	
	override public function set_properties(p:Map<String,Dynamic>):Void 
	{
		HF.copy_props(p, props);
		trigger_w = 16*Std.int(props.get("tile_w"));
		trigger_h = 16 * Std.int(props.get("tile_h"));
		type = props.get("type").toLowerCase();
		wall_type = props.get("wall_type").toLowerCase();
		if (GenericNPC.generic_npc_data.get("soundzone").exists(type+"_floor") == false) {
			Log.trace("No such soundzone floor type: " + type);
			props.set("type", "rock");
			type = "rock";
		}
		if (GenericNPC.generic_npc_data.get("soundzone").exists(wall_type+"_floor") == false) {
			Log.trace("No such soundzone wall type: " + type);
			props.set("wall_type", "rock");
			wall_type = "rock";
		}
		if (cur_type_text == null) {
			cur_type_text = HF.init_bitmap_font(type, "center", 0, 0, null, "english");
		}
		set_curtype_text_type();
		cur_type_text.text += get_modify_str();
		cur_type_text.scrollFactor.set(1, 1);
		cur_type_text.lineSpacing = 0;
		change_visuals();
	}
	
	private function get_modify_str():String {
		var s:String = " (";
		if (modify_mode == 0) {
			s += "both";
		} else if (modify_mode == 1) {
			s += "wall";
		} else if (modify_mode == 2) {
			s += "floor";
		}
		s += ")";
		return s;
	}
	
	/**
	 * Based on the modify mode, sets the displayed sound type
	 * (0 = both, 1 = wall, 2 = floor)
	 */
	function set_curtype_text_type():Void 
	{
		cur_type_text.text = wall_type + "/" + type;
		//if (modify_mode == 0) {
			//cur_type_text.text = type;
		//} else if (modify_mode == 1) {
			//cur_type_text.text = wall_type;
		//} else {
			//cur_type_text.text = type;
		//}
	}
	override public function destroy():Void 
	{
		HF.remove_list_from_mysprite_layer(this, parent_state, [drag_box,cur_type_text]);
		super.destroy();
	}
	
	private var text_mode:Int = 0;
	override public function update(elapsed: Float):Void 
	{
		if (!did_init) {
			did_init = true;
			ID = 0;
			trigger_box.width = trigger_w;
			trigger_box.height = trigger_h;
			HF.add_list_to_mysprite_layer(this, parent_state, [drag_box,cur_type_text]);
			trigger_box.move(x, y);
		}
		//Log.trace([x, y]);
		trigger_box.width = trigger_w;
		trigger_box.height = trigger_h;
		trigger_box.move(x, y);
		cur_type_text.move(x, y - 14);
		
		
		if (text_mode == 0) {
			if (FlxG.keys.pressed.SHIFT && FlxG.mouse.justPressed && FlxG.mouse.inside(cur_type_text)) {
				
				var mod_idx:Int  = cur_type_text.text.indexOf("(");
				if (mod_idx > -1) {
					var a:Int = Std.int((FlxG.mouse.x - cur_type_text.x) / cur_type_text.font.spaceWidth);
					if (a >= mod_idx) {
						modify_mode++;
						if (modify_mode == 3) modify_mode = 0;
						set_curtype_text_type();
						cur_type_text.text += get_modify_str();
						R.sound_manager.play(SNDC.menu_confirm);
						return;
					}
				}
				
				text_mode = 1;
				var sa:Array<String> = GenericNPC.generic_npc_data.get("soundzone").get("types").split(",");
				var s:String = sa.join("\n");
				cur_type_text.text = s + get_modify_str();
				
			}
		} else if (text_mode == 1) {
				var idx:Int = -1;
					var sa:Array<String> = GenericNPC.generic_npc_data.get("soundzone").get("types").split(",");
				if (FlxG.mouse.inside(cur_type_text)) {
					var offy:Int= Std.int(FlxG.mouse.y - cur_type_text.y);
					var lh:Int = cur_type_text.lineHeight + cur_type_text.lineSpacing;
					idx = Std.int(offy / lh);
					if (idx <= sa.length-1) {
						sa[idx] = sa[idx].toUpperCase();
						cur_type_text.text = sa.join("\n");
					}
					
				}
				if (FlxG.mouse.justPressed) {
					if (idx != -1) {
						got_sound = false;
						if (modify_mode == 0 || modify_mode == 2) {
							type = sa[idx].toLowerCase();
							props.set("type", type);
						}
						
						if (modify_mode == 0 || modify_mode == 1) {
							wall_type = sa[idx].toLowerCase();
							props.set("wall_type", wall_type);
						}
					}
					text_mode = 0;
					
						set_curtype_text_type();
						cur_type_text.text += get_modify_str();
					
				}
		}
		
		if (ID == 0) {
			drag_box.x = x + trigger_w - drag_box.width;
			drag_box.y = y + trigger_h - drag_box.height;
			if (FlxG.mouse.justPressed) {
				if (FlxG.mouse.inside(drag_box)) {
					ID = 1;
				}
			}
		} else if (ID == 1) {
			drag_box.x = Std.int(FlxG.mouse.x) - (Std.int(FlxG.mouse.x) % 16);
			drag_box.y = Std.int(FlxG.mouse.y) - (Std.int(FlxG.mouse.y) % 16);
			
			trigger_w = Std.int(drag_box.x + drag_box.width - x);
			trigger_h = Std.int(drag_box.y + drag_box.height - y);
			
			if (trigger_w < 16) {
				trigger_w = 16;
				drag_box.x = x + 16 - drag_box.width;
			}
			if (trigger_h < 16) {
				trigger_h = 16;
				drag_box.y = y + 16 - drag_box.height;
			}
			
			if (!FlxG.mouse.pressed) {
				props.set("tile_w", trigger_w / 16);
				props.set("tile_h", trigger_h / 16);
				trigger_box.width = trigger_w;
				trigger_box.height = trigger_h;
				ID = 0;
			}
		}
		
		if (R.editor.editor_active == false) {
			if (R.player.overlaps(trigger_box) && !got_sound) {
				got_sound = true;
				active_floor_sound = GenericNPC.generic_npc_data.get("soundzone").get(type+"_floor");
				active_wall_sound = GenericNPC.generic_npc_data.get("soundzone").get(wall_type+"_wall");
			} else {
				if (!R.player.overlaps(trigger_box)) {
					if (props.get("revert_on_exit") == 1) {
						active_floor_sound = default_floor_sound;
						active_wall_sound = default_wall_sound;
					}
					got_sound = false;
				}
			}
		} else {
			got_sound = false;
		}
		
		super.update(elapsed);
	}
	private var got_sound:Bool = false;
	override public function draw():Void 
	{
		if (R.editor.editor_active) {
			drag_box.visible = true;
			var sx:Float = FlxG.camera.scroll.x;
			var sy:Float = FlxG.camera.scroll.y;
			
			if (R.editor.hide_zones) {
				alpha = 0.1;
				drag_box.alpha = 0.1;
				cur_type_text.alpha = 0.1;
			} else {
				alpha = drag_box.alpha = 0.75;
				cur_type_text.alpha = 1;
			}
			
			if (R.editor.hide_zones) {
				FlxG.camera.debugLayer.graphics.lineStyle(1, 0x0000ff, 0.1);
			} else {
				FlxG.camera.debugLayer.graphics.lineStyle(1, 0x0000ff, 1);
			}
			FlxG.camera.debugLayer.graphics.moveTo(x-sx,y-sy);
			FlxG.camera.debugLayer.graphics.lineTo(x-sx+trigger_w,y-sy);
			FlxG.camera.debugLayer.graphics.moveTo(x-sx+trigger_w,y-sy);
			FlxG.camera.debugLayer.graphics.lineTo(x-sx+trigger_w,y+trigger_h-sy);
			FlxG.camera.debugLayer.graphics.moveTo(x-sx+trigger_w,y+trigger_h-sy);
			FlxG.camera.debugLayer.graphics.lineTo(x-sx,y+trigger_h-sy);
			FlxG.camera.debugLayer.graphics.moveTo(x-sx,y+trigger_h-sy);
			FlxG.camera.debugLayer.graphics.lineTo(x-sx,y-sy);
			super.draw();
			
			cur_type_text.visible = true;
		} else {
			
			cur_type_text.visible = false;
			drag_box.visible = false;
		}
		
	}
	
}