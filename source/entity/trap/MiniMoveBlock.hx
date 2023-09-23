package entity.trap;
import autom.SNDC;
import entity.MySprite;
import flixel.addons.tile.FlxTilemapExt;
import flixel.FlxG;
import flixel.FlxObject;
import haxe.Log;
import help.HelpTilemap;
import help.HF;
import state.MyState;

class MiniMoveBlock extends MySprite
{
	private var t_wait:Float = 0;
	private var tm_wait:Float = 0;
	public static var ACTIVE_MiniMoveBlocks:List<MiniMoveBlock>;
	
	public function new(_x:Float,_y:Float,_parent:MyState) 
	{
		super(_x, _y, _parent, "MiniMoveBlock");
	}
	
	override public function change_visuals():Void 
	{
		switch (vistype) {
			case 0:
				makeGraphic(16, 16, 0xffff00bb);
			case 1:
				makeGraphic(16, 16, 0xffffffff);
			default:
				makeGraphic(16, 16, 0xff123102);
		}
	}
	
	override public function getDefaultProps():Map<String,Dynamic> 
	{
		var p:Map<String,Dynamic> = new Map<String,Dynamic>();
		p.set("vis-dmg", "0,0");
		p.set("dir", 1);
		p.set("max_vel", 200);
		p.set("tm_wait", 0.2);
		p.set("dmg", 24);
		p.set("is_y", 0);
		p.set("max_accel", 300);
		
		return p;
	}
	
	private var dmg:Int = 0;
	private var max_accel:Float = 0;
	private var is_y:Bool = false;
	override public function set_properties(p:Map<String,Dynamic>):Void 
	{
		HF.copy_props(p, props);
		dmgtype = Std.parseInt(props.get("vis-dmg").split(",")[1]);
		vistype = Std.parseInt(props.get("vis-dmg").split(",")[0]);
		tm_wait = props.get("tm_wait");
		cur_dir = props.get("dir");
		max_vel = props.get("max_vel");
		dmg = props.get("dmg");
		is_y = props.get("is_y") == 0 ? false : true;
		max_accel = props.get("max_accel");
		change_visuals();
	}
	
	override public function destroy():Void 
	{
		if (moveplayer) {
			MOVELOCK = false;
		}
		ACTIVE_MiniMoveBlocks.remove(this);
		super.destroy();
	}
	
	override public function preUpdate():Void 
	{
		var t:FlxTilemapExt;
		for (t in [parent_state.tm_bg]) {
			if (velocity.x > 0) {
				if (parent_state.tm_bg.getTileCollisionFlags(x+width,y+height/2) != 0 && !HF.array_contains(HelpTilemap.permeable, t.getTileID(x + width, y + height / 2))) {
					touching = FlxObject.ANY;
				}
			} else if (velocity.x < 0) {
				if (parent_state.tm_bg.getTileCollisionFlags(x,y+height/2) != 0 && !HF.array_contains(HelpTilemap.permeable, t.getTileID(x, y + height / 2))) {
					touching = FlxObject.ANY;
				}
			} else if (velocity.y > 0) {
				if (parent_state.tm_bg.getTileCollisionFlags(x + width / 2 , y + height) != 0 && !HF.array_contains(HelpTilemap.permeable, t.getTileID(x+width/2, y + height))) {
					touching = FlxObject.ANY;
				}
			} else if (velocity.y < 0) {
				if (parent_state.tm_bg.getTileCollisionFlags(x + width / 2 , y ) != 0 && !HF.array_contains(HelpTilemap.permeable, t.getTileID(x+width/2, y ))) {
					touching = FlxObject.ANY;
				}
			}
		}
		super.preUpdate();
	}
	
	public function generic_overlap(o:FlxObject,only_dmgtype:Int=-1):Bool {
		if (this.dmgtype != only_dmgtype && only_dmgtype != -1) { //1 only light breaks
			return false;
		} 
		if (only_dmgtype == -1) {
			if (this.overlaps(o)) {
				return true;
			}
		}
		return false;
	}
	private static var MOVELOCK:Bool = false;
	private var mode:Int = 0;
	private var cur_dir:Int = 0;
	private var max_vel:Float = 0;
	private var is_charged:Bool = true;
	override public function update(elapsed: Float):Void 
	{
		if (!did_init) {
			did_init = true;
			ACTIVE_MiniMoveBlocks.add(this);
		}
		if (mode == 0) {
			maxVelocity.set(max_vel, max_vel);
			is_charged = true;
			switch (cur_dir) {
				case 0:
					acceleration.y = -max_accel;
				case 1:
					acceleration.x = max_accel;
				case 2:
					acceleration.y = max_accel;
				case 3:
					acceleration.x = -max_accel	;
			}
			mode = 1;
		} else if (mode == 1) {
			if (touching != 0) {
				mode = 2;
				acceleration.set(0, 0);
				velocity.set(0, 0);
			} else {
				if (!moveplayer) {
					if (R.player.overlaps(this) && is_charged) {
						is_charged = false;
						R.sound_manager.play(SNDC.OuchOutlet_Shock);
						if (MOVELOCK == false) {
							MOVELOCK = true;
							hx = R.player.x;
							hy = R.player.y;
							switch (cur_dir) {
								case 0: vx = 0; vy = -150;
								case 1: vx = 150; vy = 0;
								case 2: vx = 0; vy = 150;
								case 3: vx = -150; vy = 0;
							}
							
							moveplayer = true;
						}
						if (dmgtype == 0) {
							R.player.add_dark(dmg);
						} else {
							R.player.add_light(dmg);
						}
					}
				} 
			}
		} else if (mode == 2) {
			t_wait += FlxG.elapsed;
			if (t_wait > tm_wait) {
				t_wait = 0;
				switch (cur_dir) {
					case 0: 
						cur_dir = 2;
					case 1:
						cur_dir = 3;
					case 2:
						cur_dir = 0;
					case 3:
						cur_dir = 1;
				}
				mode = 0;
			}
		} 
		
		if (moveplayer) {
			alpha = 0.5;
			if (moveplayermode == 0) {
				R.player.velocity.set(vx, vy);
				if (Math.abs(hx - R.player.x) > 32) {
					moveplayermode = 1;
				} else if (Math.abs(hy - R.player.y) > 32) {
					moveplayermode = 1;
				}
				if (R.player.wasTouching!= 0) {
					moveplayermode = 1;
				}
				t_takingtoolong += FlxG.elapsed;
				if (t_takingtoolong > 1) {
					t_takingtoolong = 0;
					moveplayermode = 1;
				}
				if (moveplayermode == 1) {
					t_takingtoolong = 0;
				}
			} else {
				t_movetimeout += FlxG.elapsed;
				if (t_movetimeout > 0.5) {
					t_movetimeout = 0;
					moveplayer = false;
					alpha  = 1;
					MOVELOCK = false;
					moveplayermode = 0;
				}
			}
		}
		super.update(elapsed);
	}
	private var t_takingtoolong:Float = 0;
	private var t_movetimeout:Float = 0;
	private var moveplayer:Bool = false;
	private var moveplayermode:Int = 0;
	private var hx:Float = 0;
	private var vx:Float = 0;
	private var vy:Float = 0;
	private var hy:Float = 0;
	override public function postUpdate(elapsed):Void 
	{
		
		if (R.editor.editor_active && FlxG.keys.pressed.SPACE) {
		} else {
			super.postUpdate(elapsed);
		}
	}
}