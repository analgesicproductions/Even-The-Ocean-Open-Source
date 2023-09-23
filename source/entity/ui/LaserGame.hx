package entity.ui;

import autom.SNDC;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import global.Registry;
import haxe.Log;
import help.AnimImporter;
import openfl.Assets;
import openfl.display.BlendMode;
import openfl.geom.Point;

/**
 * ...
 * @author Copyright Melos Han-Tani, Developer of Analgesic Productions LLC, 2013 - ? , www.twitter.com/han_tani
 */
class LaserGame extends FlxGroup
{

	private var is_depths:Bool = false;
	private var is_set2:Bool = false;
	public function new(MaxSize:Int=0, _name:String="",mapname:String="") 
	{
		super(MaxSize, _name);
		board = new FlxSprite();
		AnimImporter.loadGraphic_from_data_with_id(board, -1, -1, "LaserBoard", "board");
		add(board);
		board.animation.play("normal");
		board.scrollFactor.set(0, 0);
		board.x = (26 * 16 - board.width) / 2;
		board.y = (16 * 16 - board.height) / 2;
		board.alpha = 0;
		
		selector = new FlxSprite();
		AnimImporter.loadGraphic_from_data_with_id(selector, -1, -1, "LaserBoard", "icons");
		selector.animation.play("selector");
		selector.scrollFactor.set(0, 0);
		
		l_start = new FlxSprite(); l_end = new FlxSprite(); d_start = new FlxSprite(); d_end = new FlxSprite();
		var a:Array<FlxSprite> = [l_start, l_end, d_start, d_end];
		for (i in 0...4) {
			AnimImporter.loadGraphic_from_data_with_id(a[i], -1, -1, "LaserBoard", "icons");
			add(a[i]);
			a[i].scrollFactor.set(0, 0);
		}
		
		l_start.animation.play("l_start");
		l_end.animation.play("l_top_open");
		d_start.animation.play("d_start");
		d_end.animation.play("d_bottom_open");
		
		reflector_group = new FlxGroup();
		add(reflector_group);
		
		l_start.x = board.x +16;
		d_start.x = board.x + 16;
		if (mapname == "") {
			mapname = Registry.R.TEST_STATE.MAP_NAME;
		}
		
		
		is_depths = false;
		is_set2 = false;
		if ( -1 != mapname.indexOf("RADIO_DB")) {
			is_depths = true;
		} else if (mapname == "BASIN_B" || mapname == "WOODS_B"  || mapname == "RIVER_B") {
			is_set2 = true;
		}
		
		var str:String = Assets.getText("assets/misc/record/lasergame.txt");
		var sa:Array<String> = str.split("\n");
		for (i in 0...sa.length) {
			var saa:Array<String> = sa[i].split(" ");
			if (saa[0] == mapname) {
				for (j in 1...saa.length) {
					var k:String = saa[j].split(",")[0];
					var arg_1:String = saa[j].split(",")[1];
					var arg_2:String = saa[j].split(",")[2];
					if (k == "l") {
						l_start.y = Std.parseInt(arg_1) * 16 + board.y + 32;
						l_start.blend = BlendMode.ADD;
					} else if (k == "d") {
						d_start.y = Std.parseInt(arg_1)*16 + board.y+32;
						d_start.blend = BlendMode.ADD;
					} else if (k == "L") {
						l_end.x = Std.parseInt(arg_1) * 16 + board.x + 32;
						if (arg_2 == "0") {
							l_end.ID = 0;
							l_end.y = board.y + 16;
						} else if (arg_2 == "4") {
							l_end.ID = 0;
							l_end.y = board.y + 4*16  + 32	;
						} else {
							l_end.ID = 8;
							l_end.y = board.y + board.height - 32;
						}
						l_end.blend = BlendMode.ADD;
					}else if (k == "D") {
						d_end.x = Std.parseInt(arg_1) * 16 + board.x + 32;
						if (arg_2 == "0") {
							d_end.ID = 0;
							d_end.y = board.y + 16;
						} else {
							d_end.ID = 8;
							d_end.y = board.y + board.height - 32;
						}
						d_end.blend = BlendMode.ADD;
					}else if (k == "ne") {
						var s:FlxSprite = new FlxSprite();
						AnimImporter.loadGraphic_from_data_with_id(s, 16, 16, "LaserBoard", "icons");
						s.animation.play("ne");
						s.scrollFactor.set(0, 0);
						s.x = board.x + 32 + 16 * Std.parseInt(arg_1);
						s.y = board.y + 32 + 16 * Std.parseInt(arg_2);
						s.ID = 0;
						s.width = s.height = 16;
						//s.offset.set(2, 2);
						reflector_group.add(s);
						s.blend = BlendMode.ADD;
					}else if (k == "se") {
						
						var s:FlxSprite = new FlxSprite();
						AnimImporter.loadGraphic_from_data_with_id(s, 16, 16, "LaserBoard", "icons");
						s.animation.play("se");
						s.scrollFactor.set(0, 0);
						s.x = board.x + 32 + 16 * Std.parseInt(arg_1);
						s.y = board.y + 32 + 16 * Std.parseInt(arg_2);
						s.ID = 1;
						s.width = s.height = 16;
						//s.offset.set(2, 2);
						reflector_group.add(s);
						s.blend = BlendMode.ADD;
					}
				} 
			}
		}
		
		selector.maxVelocity.set(95, 95);
		add(selector);
		selector.alpha = l_start.alpha = l_end.alpha = d_end.alpha = d_start.alpha = 0;
		reflector_group.setAll("alpha", 0);
		selector.blend = BlendMode.ADD;
	}
	
	// loads metadata strings
	
	// can only exiton success?
	
	// lasers
	// eleft to right
	// white to top , dark to bottom
	// refelctsors you can move
	// selectors
	public static var test_id:Int = 0;
	
	private var board:FlxSprite;
	private var l_start:FlxSprite;
	private var l_end:FlxSprite;
	private var d_start:FlxSprite;
	private var d_end:FlxSprite;
	private var reflector_group:FlxGroup;
	private var selector:FlxSprite;
	
	private var d_done:Bool = false;
	private var l_done:Bool = false;
	private var mode:Int = 0;
	private var submode:Int = 0;
	
	public var no_laser:Bool = false;
	
	
	override public function update(elapsed: Float):Void 
	{
		
		if (Registry.R.TEST_STATE.dialogue_box.is_active()) {
			selector.velocity.x = selector.velocity.y = 0;
			selector.acceleration.x = selector.acceleration.y = 0;
			super.update(elapsed);
			return;
		}
		
		if (mode == 0) {
			
		} else if (mode == 1) {
			selector.width = selector.height = 4;
			//selector.offset.set(6, 6);
			if (Registry.R.input.left) {
				selector.acceleration.x = -400;
			} else if (Registry.R.input.right) {
				selector.acceleration.x = 400;
			} else {
				selector.acceleration.x = 0;
				selector.velocity.x = 0;
			}
			if (Registry.R.input.down) {
				selector.acceleration.y = 400;
			} else if (Registry.R.input.up) {
				selector.acceleration.y = -400;
			} else {
				selector.velocity.y = 0;
				selector.acceleration.y = 0;
			}
			
			if (selector.x + selector.width > board.x +board.width -32) {
				selector.x = board.x +board.width - 32 - selector.width;
			}
			if (selector.x < board.x + 32) {
				selector.x = board.x + 32;
			}
			if (selector.y < board.y + 32) selector.y = board.y + 32;
			if (selector.y +selector.height > board.y + board.height - 32) selector.y = board.y + board.height - 32 - selector.height;
			
			if (Registry.R.input.jpA1 || Registry.R.input.jpA2) {
				for (i in 0...reflector_group.length) {
					var sp:FlxSprite = cast reflector_group.members[i];
					if (selector.overlaps(sp)) {
						if (sp.ID == 0) {
							sp.animation.play("se");
							sp.ID = 1;
						} else {
							sp.animation.play("ne");
							sp.ID = 0;
						}
						Registry.R.sound_manager.play(SNDC.menu_move);
					}
				}
			} 
			for (i in 0...reflector_group.length) {
				var sp:FlxSprite = cast reflector_group.members[i];
				if (sp.ID == 0) {
					if (selector.overlaps(sp)) {
						sp.animation.play("ne_on");
					} else {
						sp.animation.play("ne");
					}
				} else {
					if (selector.overlaps(sp)) {
						sp.animation.play("se_on");
					} else {
						sp.animation.play("se");
					}
				}
			}
			// If win:
			if ((d_done && l_done) || (FlxG.keys.pressed.Q && FlxG.keys.pressed.W && FlxG.keys.pressed.E)) {
				mode = 2;
				selector.velocity.set(0, 0);
				selector.acceleration.set(0, 0);
				Registry.R.sound_manager.play(SNDC.menu_confirm);
				board.ID = 0;
			}
		} else if (mode == 2) {
			board.ID ++;
			if (board.ID > 60) {
				board.alpha -= 0.02;
				board.alpha *= 0.98;
				if (board.alpha <= 0.02) {
					board.alpha = 0;
				}
				l_end.alpha = l_start.alpha = selector.alpha = d_end.alpha = d_start.alpha = board.alpha;
				reflector_group.setAll("alpha", board.alpha/2);
				if (board.alpha == 0) {
					// some kind of success anim
					submode = 1;
					deactivate();	
				}
			}
		} else if (mode == 3) {
			// fade in
			selector.width = selector.height = 4;
			//selector.offset.set(6, 6);
			board.alpha += 0.02;
			board.alpha *= 1.05;
			if (board.alpha >= 0.95) {
				board.alpha = 1;
			}
			l_end.alpha = l_start.alpha = selector.alpha = d_end.alpha = d_start.alpha = board.alpha;
			reflector_group.setAll("alpha", board.alpha);
			if (board.alpha == 1) {
				// some kind of success anim
				mode = 1;
			}
		}
		super.update(elapsed);
	}
	
	public function activate():Void {
		mode = 3;
		selector.x = board.x + 100;
		selector.y = board.y + 100;
		
	}
	public function is_done():Bool {
		return mode == 2 && board.alpha == 0;
	}
	public function deactivate():Void {
		//mode = 0;
		//submode = 0;
		exists = false;
	}
	
	
	override public function draw():Void 
	{
		
		
			
		// Light first, then dark
		d_start.visible = d_end.visible = true;
		for (idx in 0...2) {
			if (Registry.R.TEST_STATE.MAP_NAME == "RADIO_DB") {
				if (idx == 1) {
					d_done = true;
					d_start.visible = d_end.visible = false;
					continue;
				}
			}
			
		if (idx == 0) {
			if (Math.random() > 0.5) {
				FlxG.camera.debugLayer.graphics.lineStyle(1, 0xdfffcd, board.alpha);
			} else {
				FlxG.camera.debugLayer.graphics.lineStyle(1, 0x7aff98, board.alpha);
			}
		} else {
			if (Math.random() > 0.5) {
				FlxG.camera.debugLayer.graphics.lineStyle(1, 0xff7d85, board.alpha);
			} else {
				FlxG.camera.debugLayer.graphics.lineStyle(1, 0xc23ab7, board.alpha);
			}
		}
		
		// move the brush start to the laser start sprite
		// stroke end point
		var st:FlxPoint = new FlxPoint();
		if (idx == 0) {
			FlxG.camera.debugLayer.graphics.moveTo(l_start.x + l_start.width, l_start.y +l_start.height / 2);
		st.set(l_start.x + 8 + 16, l_start.y +8); 
		} else {
			FlxG.camera.debugLayer.graphics.moveTo(d_start.x + d_start.width, d_start.y +d_start.height / 2);
		st.set(d_start.x + 8 + 16, d_start.y +8); 
		}
		var dir:Int = 1; // 0123 urdl
		
		// reverse touching stuff
		var revidx:Bool = false;
		if (Registry.R.TEST_STATE.MAP_NAME == "RADIO_B" || Registry.R.TEST_STATE.MAP_NAME == "RADIO_B2") {
			revidx = true;
		}
		
		
		while (true) {
			// if stroke end pt moved uot of bounds, stroke to the edge of the board and exit
			if (st.x < board.x + 32 || st.x > board.x + board.width - 32 || st.y < board.y + 32 || st.y > board.y + board.height - 32) {
				if (((!revidx && idx == 0) || (revidx && idx == 1)) && l_end.overlapsPoint(st)) {
					if (l_end.ID == 0) {
						l_end.animation.play("l_top_done");
						if (is_depths) l_end.animation.play("l_side_done");
					} else {
						l_end.animation.play("l_bottom_done");
					}
					if (!l_done) Registry.R.sound_manager.play(SNDC.pew_hit);
					l_done = true;
				} else if (((!revidx && idx == 1) || (revidx && idx == 0))&& d_end.overlapsPoint(st)) {
					if (d_end.ID == 0) {
						d_end.animation.play("d_top_done");
					} else {
						d_end.animation.play("d_bottom_done");
						if (is_set2) d_end.animation.play("d_bottom_done_vent");
					}
					if (!d_done) Registry.R.sound_manager.play(SNDC.pew_hit);
					d_done = true;
				} else {
					if (((!revidx && idx == 0) || (revidx && idx == 1))) {
						l_done = false;
					} else {
						d_done = false;
					}
				}
				
				if (st.x < board.x + 32) st.x += 8;
				if (st.x > board.x + board.width - 32) st.x -= 8;
				if (st.y < board.y + 32) st.y += 8;
				if (st.y > board.y + board.height - 32) st.y -= 8;
				if (!no_laser) FlxG.camera.debugLayer.graphics.lineTo(st.x, st.y );
				
				break;
			} else {
				if (((!revidx && idx == 0) || (revidx && idx == 1))) {
					if (l_end.ID == 0) {
						l_end.animation.play("l_top_open");
						if (is_depths) l_end.animation.play("l_side_open");
					} else {
						l_end.animation.play("l_bottom_open");
					}
				} else {
					if (d_end.ID == 0) {
						d_end.animation.play("d_top_open");
					} else {
						d_end.animation.play("d_bottom_open");
						if (is_set2) d_end.animation.play("d_bottom_open_vent");
					}
				}
			}
			// If overlap reflector, stroke to the refletor, move the brush
			for (i in 0...reflector_group.length) {
				var r:FlxSprite = cast reflector_group.members[i];
				//Log.trace([r.x,r.y,st.x,st.y,dir]);
				if (r.overlapsPoint(st)) {
					// change dir
					if (dir == 0 && r.ID == 0) { // up, ne
						dir = 3;
					} else if (dir == 0 && r.ID == 1) {
						dir = 1;
					} else if (dir == 1 && r.ID == 0) { // right, ne
						dir = 2;
					} else if (dir == 1 && r.ID == 1) {
						dir = 0;
					} else if (dir == 2 && r.ID == 0) { // down, ne
						dir = 1;
					} else if (dir == 2 && r.ID == 1) {
						dir = 3;
					} else if (dir == 3 && r.ID == 0) { // left, ne
						dir = 0;
					} else if (dir == 3 && r.ID == 1) {
						dir = 2;
					}
					//Log.trace(["hit", dir]);
					if (!no_laser) FlxG.camera.debugLayer.graphics.lineTo(st.x, st.y);
					FlxG.camera.debugLayer.graphics.moveTo(st.x, st.y);
					
					break;
				}
			}
		
			// move brush pt (st)
			if (dir == 0) {
				st.y -= 16;
			} else if (dir == 1) {
				st.x += 16;
			} else if (dir == 2) {
				st.y += 16;
			} else if (dir == 3) {
				st.x -= 16;
			}
			//Log.trace([dir,st.x,st.y]);
		}
			//Log.trace(12);
		}
		 
		super.draw();
	}
	
	
	
	
	
}