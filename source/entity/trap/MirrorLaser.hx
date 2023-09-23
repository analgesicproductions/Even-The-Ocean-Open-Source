package entity.trap;
/**
 * @author Copyright Melos Han-Tani, Developer of Analgesic Productions LLC, 2013 - ? , www.twitter.com/han_tani
 */
import autom.SNDC;
import entity.MySprite;
import entity.player.Train;
import entity.util.RaiseWall;
import flash.geom.Point;
import flixel.addons.tile.FlxTilemapExt;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import haxe.Log;
import help.AnimImporter;
import help.FlxX;
import help.HelpTilemap;
import help.HF;
import state.MyState;

	class MirrorLaser extends MySprite
{
	
	public static var ACTIVE_MirrorLasers:List<MirrorLaser>;
	
	private var bumps:FlxTypedGroup<FlxSprite>;

	private var bullets:FlxTypedGroup<FlxSprite>;
	public function new(_x:Float,_y:Float,_parent:MyState) 
	{
		bullets = new FlxTypedGroup<FlxSprite>();
		bumps = new FlxTypedGroup<FlxSprite>();
		for (i in 0...4) {
			var bump:FlxSprite = new FlxSprite();
			bumps.add(bump);
		}
		super(_x, _y, _parent, "MirrorLaser");
	}
	
	override public function change_visuals():Void 
	{
		AnimImporter.loadGraphic_from_data_with_id(this, 32, 32, "MirrorLaser", "shooter");
		width = height = 16;
		offset.set(8, 8);
		animation.play("idle");
	}
	
	private function make_bullet():Void {
		var b:FlxSprite = new FlxSprite();
		bullets.add(b);
		var a:Array<Array<Float>> = [];
		for (j in 0...nr_in_row) {
			a.push([0,0]);
		}
		positions.push(a);
		b.exists = false;
		switch (vistype) {
			case 0:
				AnimImporter.loadGraphic_from_data_with_id(b, 16, 16, "MirrorLaser", "beam_l");
				for (i in 0...bumps.length) {
					var bump:FlxSprite = bumps.members[i];
					AnimImporter.loadGraphic_from_data_with_id(bump, 48, 16, "RubberLaser", "dark_bump");
				}
			case 1:
				AnimImporter.loadGraphic_from_data_with_id(b, 16, 16, "MirrorLaser", "beam_d");
				for (i in 0...bumps.length) {
					var bump:FlxSprite = bumps.members[i];
					AnimImporter.loadGraphic_from_data_with_id(bump, 48, 16, "RubberLaser", "light_bump");
				}
			default:
				AnimImporter.loadGraphic_from_data_with_id(b, 16, 16, "MirrorLaser", "beam_l");
				for (i in 0...bumps.length) {
					var bump:FlxSprite = bumps.members[i];
					AnimImporter.loadGraphic_from_data_with_id(bump, 48, 16, "RubberLaser", "dark_bump");
				}
		}
		
		for (i in 0...bumps.length) {
			var bump:FlxSprite = bumps.members[i];
			bump.exists = false;
			bump.origin.set(0, 0);
		}
		b.width = b.height = 4;
		b.offset.set(4, 4);
		b.animation.play("big");
	}
	
	function find_And_init_bullet():Bool 
	{
		for (i in 0...bullets.length) {
			if (bullets.members[i].exists == false) {
				var b:FlxSprite = bullets.members[i];
				b.exists = true;
				switch (props.get("dir")) {
					case 0:
						b.velocity.set( -bul_vel, -bul_vel);
					case 1:
						b.velocity.set(bul_vel, -bul_vel);
					case 2:
						b.velocity.set(bul_vel, bul_vel);
					case 3:
						b.velocity.set(-bul_vel, bul_vel);
				}
				if (rhythm[rhythm_idx] == 1) {
					//b.animation.play("dark");
					b.ID = 1;
					AnimImporter.loadGraphic_from_data_with_id(b, 16, 16, "MirrorLaser", "beam_d");
					b.width = b.height = 8;
					b.offset.set(4,4);
				} else if (rhythm[rhythm_idx] == 2) {
					//b.animation.play("light");
					b.ID = 2;
					AnimImporter.loadGraphic_from_data_with_id(b, 16, 16, "MirrorLaser", "beam_l");
					b.width = b.height = 8;
					b.offset.set(4,4);
				}
				
				b.x = b.last.x = x + (width - b.width) / 2;
				b.y = b.last.y = y + (height - b.height) / 2;
				b.x += b.velocity.x * 4 * FlxG.elapsed;
				b.y += b.velocity.y * 4 * FlxG.elapsed;
				
				b.alpha = 1;
				
				for (j in 0...nr_in_row) {
					positions[i][j][0] = b.x;
					positions[i][j][1] = b.y;
					
				}
				
				return true;
			}
		}
		return false;
	}
	private var t_TICKS:Int = 0;
	private var tm_TICKS:Int = 0;
	override public function getDefaultProps():Map<String,Dynamic> 
	{
		var p:Map<String,Dynamic> = new Map<String,Dynamic>();
		p.set("vis-dmg", "0,0");
		p.set("pattern", "1,0,1,1");
		p.set("init_wait", 0);
		p.set("t_shoot", 0.5);
		p.set("dir", 0);
		p.set("dmg", 48);
		p.set("vel", 50);
		p.set("t_TICKS", 0);
		return p;
	}
	
	private var positions:Array<Array<Array<Float>>>;
	private var nr_in_row:Int = 7;
	private var t_shoot:Float = 0;
	private var tm_shoot:Float = 0;
	private var init_wait:Float = 0;
	private var bul_vel:Float = 0;
	override public function set_properties(p:Map<String,Dynamic>):Void 
	{
		HF.copy_props(p, props);
		
		bullets.callAll("destroy");
		bullets.clear();
		
		dmgtype = Std.parseInt(props.get("vis-dmg").split(",")[1]);
		vistype = Std.parseInt(props.get("vis-dmg").split(",")[0]);
		bul_vel = props.get("vel");
		positions = [];
		tm_shoot = props.get("t_shoot");
		init_wait = props.get("init_wait");
		rhythm = HF.string_to_int_array(props.get("pattern"),true);
		rhythm_idx = -1;
		change_visuals();
		var dir:Int = props.get("dir");
		switch (dir) {
			case 0: angle = 0;
			case 1: angle = 90;
			case 2: angle = 180;
			case 3: angle = 270;
		}
		
		if (props.get("t_TICKS") > 0) {
			tm_TICKS = props.get("t_TICKS");
			t_TICKS = tm_TICKS;
		}
		_p = new Point();
	}
	
	override public function destroy():Void 
	{
		HF.remove_list_from_mysprite_layer(this, parent_state, [bullets, bumps]);
		bumps.destroy();
		bullets.destroy();
		ACTIVE_MirrorLasers.remove(this);
		super.destroy();
	}
	
	private var ctr_update_pos:Int = 0;
	private var rhythm:Array<Int>;
	private var rhythm_idx:Int;
	private var _p:Point;
	override public function update(elapsed: Float):Void 
	{
		if (!did_init) {
			did_init = true;
			ACTIVE_MirrorLasers.add(this);
			HF.insert_list_before_object_in_mysprite_layer(this, parent_state, [bullets]);
			HF.add_list_to_mysprite_layer(this, parent_state, [bumps]);
		}
		
		for (i in 0...bumps.length) {
			var bump:FlxSprite = bumps.members[i];
			if (bump.exists) {
				if (null != bump.animation.curAnim) {
					if (bump.animation.finished) {
						bump.exists = false;
					}
				}
			}
		}
		
		
		if (init_wait > 0) {
			init_wait -= FlxG.elapsed;
			super.update(elapsed);
			return;
		}
		
		var shootonticks:Bool = false;
		if (tm_TICKS > 0) {
			t_TICKS ++;
			if (t_TICKS >= tm_TICKS) {
				t_TICKS = 0;
				shootonticks = true;
			}
			
		}
		t_shoot += FlxG.elapsed;
		if (t_shoot > tm_shoot || shootonticks) {
			rhythm_idx++;
			t_shoot = 0;
			if (rhythm_idx == rhythm.length) {
				rhythm_idx = 0;
			}
			if (rhythm[rhythm_idx] == 1 || rhythm[rhythm_idx] == 2) {
				t_shoot -= tm_shoot;
				var found:Bool = find_And_init_bullet();
				if (!found) {
					if (bullets.length < 25) {
						make_bullet();
						find_And_init_bullet();
					}
				}
				animation.play("shoot");
			}
		}
		
		if (t_hurt > 0) {
			t_hurt -= FlxG.elapsed;
		}
		var player_shield:FlxObject = R.player.get_active_shield_logic();
		for (i in 0...bullets.length) {
			var b:FlxSprite = bullets.members[i];
			if (b.exists) {
				
				if (b.ID == 3) {
					b.alpha -= 0.125;
				}
				
				var ovx:Float = b.velocity.x;
				var ovy:Float = b.velocity.y;
				if (player_shield != null && R.player.shield_overlaps(b)) {
					var sd:Int = R.player.get_shield_dir();
					
					//R.sound_manager.play(SNDC.pew_wall,1,true,this);
					R.sound_manager.play(SNDC.pew_hit_shield);
					if (b.velocity.x > 0 && sd == 3 || b.velocity.x < 0 && sd == 1) {
						b.x = b.last.x;
						b.velocity.x = -ovx;
					}
					if (b.velocity.y > 0 && sd == 0 || b.velocity.y < 0 && sd == 2) {
						b.y = b.last.y;
						b.velocity.y = -ovy;
					}
					t_hurt = 0.05;
				}else if (b.overlaps(R.player) && t_hurt <=	 0) {
					//b.exists = false;
								b.velocity.set(0, 0);
					if (b.ID == 1) {
					R.sound_manager.play(SNDC.pew_hit);
						R.player.add_dark(props.get("dmg"));
					} else if (b.ID == 2) {
					R.sound_manager.play(SNDC.pew_hit);
						R.player.add_light(props.get("dmg"));
					}
								b.ID = 3;
				}
				
					for (rw in RaiseWall.ACTIVE_RaiseWalls.members) {
						if (rw != null) {
							if (rw.overlaps(b)) {
								//b.exists = false;
								b.ID = 3;
								b.velocity.set(0, 0);
							}
						}
					}
				
				
				
				if (parent_state.tm_bg.getTileCollisionFlags(b.x + b.width / 2, b.y + b.height / 2) != 0) {
					_p.x = b.x + b.width / 2;
					_p.y = b.y + b.height / 2;
					
					var tid:Int = parent_state.tm_bg.getTileID(_p.x, _p.y);
					
					// _p is center of bullet
					
					var mirrored:Bool = HF.array_contains(HelpTilemap.mirror, tid);
					
					var tm:FlxTilemapExt = parent_state.tm_bg;
					
					if (HF.array_contains(HelpTilemap.permeable, tid)) {
						
					// check for collisions
					} else {
						if (!mirrored) {
							//b.exists = false;
							b.ID = 3;
							b.velocity.set(0, 0);
						} else {
							b.y -= FlxG.elapsed * b.velocity.y;
							b.x -= FlxG.elapsed * b.velocity.x;
							var bump:FlxSprite = null;
							for (i in 0...bumps.length) {
								bump = bumps.members[i];
								if (bump != null && !bump.exists) {
									bump.exists = true;
									bump.animation.play("bump");
									break;
								}
							}
						
							if (b.velocity.y > 0) {
								if (tm.getTileCollisionFlags(b.x + b.width / 2, b.y + b.height) != 0) {
									b.velocity.y *= -1;
									if (bump != null) {
										bump.angle = 0;
										bump.move(b.x + b.width / 2 - bump.width / 2, b.y);
									}
								}
								b.y += FlxG.elapsed * b.velocity.y;
							} else if (b.velocity.y < 0) {
								if (tm.getTileCollisionFlags(b.x + b.width / 2, b.y) != 0) {
									b.velocity.y *= -1;
									if (bump != null) {
										bump.angle = 0;
										bump.move(b.x + b.width / 2 - bump.width / 2, b.y-bump.height+8);
									}
								}
								b.y += FlxG.elapsed * b.velocity.y;
								
							}
							if (b.velocity.x > 0) {
								if (tm.getTileCollisionFlags(b.x + b.width, b.y + b.height / 2) != 0) {
									b.velocity.x *= -1;
								if (bump != null) {
									bump.angle = 90;
									bump.move(b.x + b.width +8 , b.y -12 + b.height/2 -bump.height/2);
								}
								}
								b.x += FlxG.elapsed * b.velocity.x;
							} else if (b.velocity.x < 0) {
								if (tm.getTileCollisionFlags(b.x, b.y + b.height / 2) != 0) {
									b.velocity.x *= -1;
								if (bump != null) {
									bump.angle = 90;
									bump.move(b.x + 36 - bump.width / 2, b.y-16 + bump.height/2);
								}
								}
								b.x += FlxG.elapsed * b.velocity.x;
							}
						}
					}
				}
			}
		}
		
		
		t_update_drawpos += elapsed;
		
		if (t_update_drawpos > 0.014) {
			t_update_drawpos = 0;
			for (i in 0...bullets.length) {
				if (bullets.members[i].exists && bullets.members[i].ID != 3) {
					positions[i][t_drawpos_idx][0] = bullets.members[i].x;
					positions[i][t_drawpos_idx][1] = bullets.members[i].y;
					positions[i][t_drawpos_idx][2] = 1;
					
					//for (j in 0...nr_in_row) {
						//// last
						//if (j == nr_in_row - 1) {
							//positions[i][0][0] = bullets.members[i].x;
							//positions[i][0][1] = bullets.members[i].y;
							//positions[i][0][2] = 1;
						//} else {
							//positions[i][nr_in_row - j - 1][0] = positions[i][nr_in_row - j - 2][0];
							//positions[i][nr_in_row - j - 1][1] = positions[i][nr_in_row - j - 2][1];
						//}
					//}
				}
			}
			t_drawpos_idx ++;
			if (t_drawpos_idx == nr_in_row) {
				t_drawpos_idx = 0;
			}
		}
		super.update(elapsed);
	}
	private var t_update_drawpos:Float = 0;
	private var t_drawpos_idx:Int = 0;// fuc fuck
	
	private var t_hurt:Float = 0;
	override public function draw():Void 
	{
		
		// bllets render normally, draw a trail
		for (i in 0...bullets.length) {
			var b:FlxSprite = bullets.members[i];
			var ox:Float = b.x;
			var oy:Float = b.y;
			var nrok:Int = 0;
			var oa:Float = b.alpha;
			if (b.exists) {
				for (j in 0...nr_in_row) {
					b.x = positions[i][j][0];
					b.y = positions[i][j][1];
					b.alpha = positions[i][j][2];
					b.animation.play("small");
					
					if (positions[i][j][2] != -1) {
						b.draw();
					}
					if (b.ID == 3) {
						positions[i][j][2] -= 0.185;
						if (j == t_drawpos_idx -1) {
							positions[i][j][2] = 0;
						} else if (t_drawpos_idx == 0 && j == nr_in_row - 1) {
							positions[i][j][2] = 0;
						}
					} else {
						positions[i][j][2] *= 0.7;
					}
					if (positions[i][j][2] <= 0) {
						nrok ++;
						positions[i][j][2]  = -1;
					}
				}
				b.x = ox;
				b.y = oy;
				if (b.ID == 3 && nrok == nr_in_row) {
					b.exists = false;
					//R.sound_manager.play(SNDC.pew_wall);
				}
			}
			b.alpha = oa;
			if (b.ID == 3) {
				b.alpha -= 0.125;
			} else {
				b.alpha = 1;
			}
			b.animation.play("big");
			//if (i == bullets.length - 1) {
				if (b.exists && b.ID != 3) b.draw();
			//}
		}
		super.draw();
	}
	
	public var lastcolor:Int = 0;
	public function generic_overlap(o:FlxObject,remove_bul:Bool=false,only:Int=-1,whygod:Int=-1):Bool {
		var bul:FlxSprite;
		for (i in 0...bullets.length) {
			bul = bullets.members[i];
			// 1 = dark, bul.ID = 2 = light
			if (bul.exists && bul.overlaps(o)) {
				if (only != -1) {
					if (only == 0 && bul.ID == 2) { // Only takes dark, bul is light
						if (remove_bul) bul.exists = false;
						return false;
					} else if (only == 1 && bul.ID == 1) {
						if (remove_bul) bul.exists = false;
						return false;
					}
				}
				if (whygod != -1) {
					if (bul.ID == 2 && whygod == 0) {
						return true;
					} else if (bul.ID == 1 && whygod == 1) {
						return true;
					}
					if (remove_bul) {
						bul.exists = false;
					}
					return false;
				}
				if (remove_bul) {
					bul.exists = false;
				}
				lastcolor = bul.ID;
				return true;
			}
		}
		return false;
	}
	
	public function generic_circle_overlap(cx:Float,cy:Float,cr:Float, type:Int = -1):Bool {
		var bul:FlxSprite;
		
		for (i in 0...bullets.length) {
			bul = bullets.members[i];
			if (bul.exists && FlxX.circle_flx_obj_overlap(cx,cy,cr,bul) ) {
				if (type == 1 || type == -1) {
					if (dmgtype == 1) {
						return true;
					}
				} else if (type == 0 ) {
					if (dmgtype == 0) {
						return true;
					}
				} else {
					return true;
				}
			}
		} 
		return false;
	}
	
}