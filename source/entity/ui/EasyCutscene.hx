package entity.ui;
import autom.SNDC;
import flash.display.BlendMode;
import flixel.text.FlxBitmapText;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import global.C;
import global.Registry;
import haxe.Log;
import haxe.Utf8;
import help.DialogueManager;
import help.HF;
import openfl.Assets;
import state.TestState;
import state.TitleState;
import sys.FileSystem;
import sys.io.File;

/**
 * ...
 * @author Copyright Melos Han-Tani, Developer of Analgesic Productions LLC, 2013 - ? , www.twitter.com/han_tani
 */
class EasyCutscene extends FlxGroup
{

	public var fg_fade:FlxSprite;
	public var sprites:FlxTypedGroup<FlxSprite>;
	public var lp:LyricsPlayer;
	private var R:Registry;
	
	private var hash:Map<String,FlxSprite>;
	
	public var ping_1:Bool = false;
	public var ping_last:Bool = false;
	public function new() 
	{
		super();
		R = Registry.R;
	}
	
	private var sta:Dynamic;
	
	private var stash_cam_pos:FlxPoint;
	
	private var lines:Array<String>;
	private var testing:Bool = false;
	private var scale_to_zero_sprites:Array<FlxSprite>;
	private var scale_to_zero_rates:Array<Float>;
	
	
	public function start(id:String, st:Dynamic = null, reset:Bool = false, testing:Bool = false,incamzone:Bool=false):Void {
		activate(id, st, reset, testing,incamzone);
	}
	public function activate(id:String, st:Dynamic=null,reset:Bool=false,testing:Bool=false,incamzone:Bool=false):Void {
		if (mode != 0 && !reset) {
			Log.trace("not playing " + id);
			Log.trace([mode, reset]);
			return;
		}
		if (st == null) {
			st = R.TEST_STATE;
		}
		
		
		if (lp == null) {
			lp = new LyricsPlayer();
		}
		
		scale_to_zero_sprites = [];
		scale_to_zero_rates = [];
		
		this.testing = testing;
		if (reset) {
			Log.trace("resetting " + id);
			deactivate();
		} else {
			Log.trace("starting " + id);
		}
		
		// Get easycutscene data, copy it from dev if necessary
		id += ".txt";
		if (Assets.exists("assets/script/cutscene/easy/" + id) == false) {
			Log.trace("No such easycutscene script " + id);
			return;
		}
		//if (R.editor == null || false == R.editor.editor_active) {
			//lines = Assets.getText("assets/script/cutscene/easy/" + id).split("\n");
		//} else 
		
		if (ProjectClass.DEV_MODE_ON == false) {
			lines = Assets.getText("assets/script/cutscene/easy/" + id).split("\n");
		} else { // If the editor is active, copy the dev-copy to the build-copy
			#if cpp
			if (FileSystem.exists(C.EXT_ASSETS + "script/cutscene/easy/"+ id)) {
				lines = File.getContent(C.EXT_ASSETS + "script/cutscene/easy/" + id).split("\n");
				HF.copy(C.EXT_ASSETS + "script/cutscene/easy/" + id, "assets/" + "script/cutscene/easy/" + id);
			} else {
				Log.trace("Tried to copy dev->build, No such easycutscene script " + id);
			}
			#end
		}
		
		
		if (fg_fade == null) {
			fg_fade = new FlxSprite();
			fg_fade.makeGraphic(432, 256, 0xff000000);
			fg_fade.color = 0;
			fg_fade.alpha = 0;
			fg_fade.scrollFactor.set(0, 0);
		}
		
		fg_fade.exists = fg_fade.visible = true;
		fg_fade.alpha = 0;
		
		if (sprites == null) {
			sprites = new FlxTypedGroup<FlxSprite>();
		}
		mode = 1;
		interp_mode = IMODE_INTERP;
		submode = 0;
		exists = true;
		if (Std.is(st,TestState)) {
			st.gui_sprites.add(this);
		}
		this.sta = st;
		
		add(sprites);
		add(fg_fade);
		
		stash_cam_pos = new FlxPoint(FlxG.camera.scroll.x, FlxG.camera.scroll.y);
		hash = new Map<String,FlxSprite>();
		
		s_list = [];
		sprites.setAll("ID", -1);
		sprites.setAll("alpha", 0);
		sprites.setAll("exists", false);
		
		idx = -1;
		
		
		if (Std.is(sta,TestState)) {
			R.player.energy_bar.force_hide = true;
			R.player.energy_bar.allow_move = false;
			R.player.energy_bar.dont_move_cutscene_bars = true;
		}
		if (testing) {
			R.TEST_STATE.dialogue_box.speaker_always_none = true;
		}
		
		
		if (!incamzone) {
			FlxG.camera.setScrollBoundsRect(0, 0, R.TEST_STATE.tm_bg.widthInTiles * 16, R.TEST_STATE.tm_bg.heightInTiles * 16, true);
		}
	}
	
	private function add_sprite(vname:String,filename:String,w:Int,h:Int,alpha:Float,x:Int,y:Int):Void {
		var s:FlxSprite = null;
		if (filename == "bg/intro/energy" || filename == "bg/intro/plants" || filename == "bg/intro/wf") {
			filename = "assets/sprites/" + filename;
			if (R.dialogue_manager.get_langtype() != 0) filename += DialogueManager.arrayLANGTYPEcaps[R.dialogue_manager.get_langtype()];
		} else {
			filename = "assets/sprites/" + filename;
		}
		filename += ".png";
		for (i in 0...sprites.members.length) {
			if (sprites.members[i].ID == -1) {
				s = sprites.members[i];
				break;
			}
		}
		if (s == null) {
			s = new FlxSprite();
			sprites.add(s);
		}
		s.velocity.set(0, 0);
		s.scrollFactor.set(1, 1);
		s.acceleration.set(0, 0);
		s.myLoadGraphic(Assets.getBitmapData(filename), true, false, w, h);
		s.ID = 0;
		s.move(x, y);
		s.scale.set(1, 1);
		s.exists = true;
		s.alpha = alpha;
		s.angle = 0;
		hash.set(vname, s);
	}
	
	public function deactivate():Void {
		if (Std.is(sta,TestState)) {
			sta.gui_sprites.remove(this, true);
			R.player.energy_bar.force_hide = false;
			R.player.energy_bar.allow_move = true;
			if (R.player.energy_bar.OFF) {
				R.player.energy_bar.dont_move_cutscene_bars = false;
			}
			R.TEST_STATE.dialogue_box.speaker_always_none = false;

		}
			R.TITLE_STATE.dialogue_box.speaker_always_none = false;
	}
	
	public function is_off():Bool {
		if (mode == 0) return true;
		return false;
	}
	private var mode:Int = 0;
	private var idx:Int = 0;
	
	private var interp_mode:Int = 0;
	private var IMODE_INTERP:Int = 0;
	private var IMODE_FADE:Int = 1;
	private var IMODE_D_BLOCK:Int = 2;
	private var IMODE_FADE_A:Int = 3;
	private var IMODE_WAIT:Int = 4;
	private var IMODE_STOP_AT:Int = 5;
	private var IMODE_INPUT_BLOCK:Int = 6;
	private var IMODE_PAN:Int = 7;
	private var IMODE_FADE_SCALE:Int = 8;
	private var IMODE_TITLE_CARD:Int = 9;
	private var IMODE_LYRICS_BLOCK:Int = 10;
	
	private var s_list:Array<FlxSprite>;
	private var coord_list:Array<Float>;
	
	private function update_interp():Void {
		if (ping_1 || ping_last) {
			return;
		}
		while (true) {
			idx++;
			var line:String = lines[idx];
			if (line.length <= 2 || line.charAt(0) == "/") {
				continue;
			}
			
			line = StringTools.rtrim(line);
			var t:Array<String> = line.split(" ");
			var fname:String = t[0];
			
			switch (fname) {
				// Blocking (goes to diffeerent state)
				
				//// fade in the black overlay
				//fade <add_rate>
				case "title_card":
					R.TEST_STATE.eae.turn_on(t[1]);
//R.TEST_STATE.eae.turn_on("CITY");
//R.TEST_STATE.eae.is_off()
					continue;
				case "wait_title_card":
					interp_mode = IMODE_TITLE_CARD;
				case "fade":
					interp_mode = IMODE_FADE;
					fgfaderate = pf(t[1]);
					if (t.length > 2) {
						if (fg_fade.color != 0xffffff) {
							fg_fade.makeGraphic(416, 256, 0xffffffff);
							fg_fade.color = 0xffffff;
						}
					} else {
						if (fg_fade.color != 0) {
							fg_fade.makeGraphic(416, 256, 0xff000000);
							fg_fade.color = 0;
						}
					}
					
				//fade_alpha <list> <mul_rate>
				case "fade_alpha":
					interp_mode = IMODE_FADE_A;
					fgfaderate = pf(t[2]);
					var l:Array<String> = t[1].split(",");
					s_list = [];
					for (token in l) {
						if (hash.exists(token)) {
							s_list.push(hash.get(token));
						}
					}
				// scale_to_zero <var> <dest_scale> <rate/frame>
				case "scale_to_zero":
					if (hash.exists(t[1])) {
						scale_to_zero_sprites.push(hash.get(t[1])); 
						scale_to_zero_rates.push(pf(t[2]));
						scale_to_zero_rates.push(pf(t[3]));
					}
					continue;
				// fade_scale <varlist>  <xs1,ys1,rxs1,rys1...>
				case "fade_scale":
					interp_mode = IMODE_FADE_SCALE;
					coord_list = HF.string_to_float_array(t[2]);
					
					var l:Array<String> = t[1].split(",");
					s_list = [];
					for (token in l) {
						if (hash.exists(token)) {
							s_list.push(hash.get(token));
						}
					}
				case "blend":
					var l:Array<String> = t[1].split(",");
					for (token in l) {
						if (hash.exists(token)) {
							if (pi(t[2]) == 1) {
								hash.get(token).blend = BlendMode.ADD;
							} else if (pi(t[2]) == 2) {
								hash.get(token).blend = BlendMode.MULTIPLY;
							}else if (pi(t[2]) == 3) {
								hash.get(token).blend = BlendMode.SCREEN;
							}
						}
					}
					continue;
				case "angle":
						
					var l:Array<String> = t[1].split(",");
					for (token in l) {
						if (hash.exists(token)) {
							hash.get(token).angle = pi(t[2]);
						}
					}
					continue;
				//wait <seconds>
				case "wait":
					interp_mode = IMODE_WAIT;
					fgfaderate = pf(t[1]);
					
				//// blocks until varname reaches <x,y>.
				//stop_at <varlist> <x1,y1,x2,y2,...>
				case "stop_at":
					s_list = [];
					var l:Array<String> = t[1].split(",");
					coord_list = HF.string_to_float_array(t[2]);
					for (token in l) {
						if (hash.exists(token)) {
							s_list.push(hash.get(token));
						}
					}
					
					interp_mode = IMODE_STOP_AT;
				case "lyrics":
					add(lp);
					lp.activate(t[1], t[2]);
				case "lyrics_block":
					interp_mode = IMODE_LYRICS_BLOCK;
				// blocks tilld ialogue done
				// d_block
				case "d_block":
					interp_mode = IMODE_D_BLOCK;
				case "wait_for_input":
					interp_mode = IMODE_INPUT_BLOCK;
					
				/* nonblocking (runs next cmd) */
				
				//dialogue <m> <s> <p>
				case "dialogue":
					
					if (Std.is(sta,TestState)) {
						R.TEST_STATE.dialogue_box.IS_SCREEN_AREA = true;
						R.TEST_STATE.dialogue_box.start_dialogue(t[1], t[2], pi(t[3]));
					} else if (Std.is(sta, TitleState)) {
						R.TITLE_STATE.dialogue_box.IS_SCREEN_AREA = true;
						R.TITLE_STATE.dialogue_box.start_dialogue(t[1], t[2], pi(t[3]));
					}
					
					continue;
					
				// adds varname,sprite to hash for later lookup. sets ID to 0 to indicate 'taken'. looks for a -1 ID otherwise.
				//add <varname> <filename> <w> <h> <a> <x> <y>
				case "add":
					add_sprite(t[1], t[2], pi(t[3]), pi(t[4]), pf(t[5]), pi(t[6]), pi(t[7]));
					if (t.length > 9) {
						hash.get(t[1]).scrollFactor.set(pf(t[8]), pf(t[9]));
			//metadata = EMBED_TILEMAP.prlx_meta_hash.get(bg_prlx_set[i]).split(",");
			//
			//fs.scrollFactor.set(Std.parseFloat(metadata[3]), Std.parseFloat(metadata[4]));
					}
					continue;
					
				//vel <varlist> <x> <y>
				case "vel":
					var l:Array<String> = t[1].split(",");
					for (token in l) {
						if (hash.exists(token)) {
							hash.get(token).velocity.x = pf(t[2]);
							hash.get(token).velocity.y = pf(t[3]);
						}
					}
					continue;
				//accel <varlist> <x> <y>
				case "accel":
					var l:Array<String> = t[1].split(",");
					for (token in l) {
						if (hash.exists(token)) {
							hash.get(token).acceleration.x = pf(t[2]);
							hash.get(token).acceleration.y = pf(t[3]);
						}
					}
					continue;
				//pos <varname> <x> <y>
				case "pos":
					var l:Array<String> = t[1].split(",");
					for (token in l) {
						if (hash.exists(token)) {
							hash.get(token).move(pf(t[2]), pf(t[3]));
						}
					}
					continue;
				// alpha <varlist> <newval>
				case "alpha":
					var l:Array<String> = t[1].split(",");
					for (token in l) {
						if (hash.exists(token)) hash.get(token).alpha = pf(t[2]);
					}
					continue;
					
				//particles <p_id>
				//particles_stop
				case "particles":
					continue;
				case "particles_stop":
					continue;
				// music <songname>
				case "music":
					if (t.length > 2) {
						R.song_helper.fade_to_this_song(t[1], true, t[2]);
					} else {
						R.song_helper.fade_to_this_song(t[1]);
					}
					continue;
				// sound <filename>
				case "sound":
					R.sound_manager.play(t[1]);
					continue;
					
				//// if no vel specified, instantly moves
				// always takes 0.5 s to accel and deccel
				//cam_to <x> <y> <time>
				case "cam_to":
					FlxG.camera.follow(null);
					
					if (t.length > 3) {
						interp_mode = IMODE_PAN;
						coord_list = [pf(t[1]), pf(t[2]), pf(t[3])];
						submode = 0;
					} else {
						//Log.trace(FlxG.camera.scroll);
						FlxG.camera.scroll.set(pi(t[1]),pi(t[2]));
						FlxG.camera._scrollTarget.set(pi(t[1]), pi(t[2]));
						//Log.trace(FlxG.camera.scroll);
						continue;
					}
				// unstash_cam
				// returns cam pos to original position and follows player
				case "unstash_cam":
					if (Std.is(sta,TestState)) {
						FlxG.camera.scroll.set(stash_cam_pos.x, stash_cam_pos.y);
						FlxG.camera._scrollTarget.set(stash_cam_pos.x, stash_cam_pos.y);
						if (t.length > 1 && t[1] == "false") {
							
						} else {
							FlxG.camera.follow(R.player);
						}
						TestState.truly_set_default_cam(R.TEST_STATE.tm_bg.width, R.TEST_STATE.tm_bg.height);
					}
					continue;
				// add_anim <varlst> <name> <frames> <fr> <loops (0/1)>
				case "add_anim":
					var l:Array<String> = t[1].split(",");
					for (token in l) {
						if (hash.exists(token)) hash.get(token).animation.add(t[2], HF.string_to_int_array(t[3]), pi(t[4]), 1 == pi(t[5]));
					}
					continue;
				// play_anim <varlist> <name>
				case "play_anim":
					var l:Array<String> = t[1].split(",");
					for (token in l) {
						if (hash.exists(token)) hash.get(token).animation.play(t[2], true);
					}
					continue;
				// return controlt o game
				case "done":
					R.TEST_STATE.dialogue_box.IS_SCREEN_AREA = false;
					R.TITLE_STATE.dialogue_box.IS_SCREEN_AREA = false;
					mode = 3;
				case "ping_1":
					ping_1 = true;
					if (testing) {
						ping_1 = false;
						continue;
					}
				// takes advantage of the easycutscene's fade. will be reset at beginning of hcange map in teststate
				case "ping_last":
					ping_last = true;
					if (testing) {
						ping_last = false;
						continue;
					}
			}
			
			break;
		}
	}
	
	private function pi(s:String):Int {
		return Std.parseInt(s);
	}
	private function pf(s:String):Float {
		return Std.parseFloat(s);
	}
	
	private var fgfaderate:Float = 0;
	private var submode:Int = 0;
	private var pan_ax:Float = 0;
	private var pan_ay:Float = 0;
	private var pan_vx:Float = 0;
	private var pan_vy:Float = 0;
	private var pan_mvx:Float = 0;
	private var pan_mvy:Float = 0;
	private var pan_a_time:Float = 0;
	private var pan_cv_time:Float = 0; // constant vel
	override public function update(elapsed: Float):Void 
	{
		if (mode == 0) {
			
		} else if (mode == 1) {
			
			if (scale_to_zero_sprites.length > 0) {
				for (i in 0...scale_to_zero_sprites.length) {
					if (scale_to_zero_sprites[i].scale.x > scale_to_zero_rates[i * 2]) {
						scale_to_zero_sprites[i].scale.x -= scale_to_zero_rates[1+i * 2];
						scale_to_zero_sprites[i].scale.y -= scale_to_zero_rates[1 + i * 2];
					}
				}
			}
			
			if (interp_mode == IMODE_INTERP) {
				update_interp();
			} else if (interp_mode == IMODE_LYRICS_BLOCK) {
				if (lp.is_done()) {
					interp_mode = IMODE_INTERP;
					remove(lp, true);
				}
			} else if (interp_mode == IMODE_TITLE_CARD) {
				if (R.TEST_STATE.eae.is_off()) {
					interp_mode = IMODE_INTERP;
				}
			} else if (interp_mode == IMODE_INPUT_BLOCK) {
				if (R.input.jp_any()) {
					interp_mode = IMODE_INTERP;
				}
			} else if (interp_mode == IMODE_PAN) {
				if (submode == 0) {
					pan_a_time =  0.5;
					pan_cv_time = coord_list[2] - 2 * pan_a_time;
					
					// Accel for 0.5 sec, constant vel, then decel for 0.5 sec
					// pan_cv_time = (xd - xi)/vx  -0.5
					// mvx = (xd-xi)/(t_no_accel+0.5)
					
					pan_vx = 0; pan_vy = 0;
					
					pan_mvx = (coord_list[0] - FlxG.camera.scroll.x) / (pan_cv_time + pan_a_time);
					pan_mvy = (coord_list[1] - FlxG.camera.scroll.y) / (pan_cv_time + pan_a_time);
					
					pan_ax = pan_mvx / pan_a_time;
					pan_ay = pan_mvy / pan_a_time;
					
					submode = 1;
					
					
					// accel = 2v
					//accel for 0.5 sec
				} else if (submode == 1) {
					pan_vx += FlxG.elapsed * pan_ax;
					pan_vy += FlxG.elapsed * pan_ay;
					var ct:Int = 0;
					if (pan_vx < 0) {
						if (pan_vx <= pan_mvx) {
							pan_vx = pan_mvx;
							ct++;
						}
					} else {
						if (pan_vx >= pan_mvx) {
							pan_vx = pan_mvx;
							ct++;
						}
					}
					if (pan_vy < 0) {
						if (pan_vy <= pan_mvy) {
							pan_vy = pan_mvy;
							ct++;
						}
					} else {
						if (pan_vy >= pan_mvy) {
							pan_vy = pan_mvy;
							ct++;
						}
					}
					if (ct== 2) {
						submode = 2;
					}
					
					FlxG.camera.scroll.x += FlxG.elapsed * pan_vx;
					FlxG.camera._scrollTarget.x += FlxG.elapsed * pan_vx;
					FlxG.camera.scroll.y += FlxG.elapsed * pan_vy;
					FlxG.camera._scrollTarget.y += FlxG.elapsed * pan_vy;
				} else if (submode == 2) {
					FlxG.camera.scroll.x += FlxG.elapsed * pan_vx;
					FlxG.camera._scrollTarget.x += FlxG.elapsed * pan_vx;
					FlxG.camera.scroll.y += FlxG.elapsed * pan_vy;
					FlxG.camera._scrollTarget.y += FlxG.elapsed * pan_vy;
					
					pan_cv_time -= FlxG.elapsed;
					if (pan_cv_time <= 0) {
						submode = 3;
					}
				} else if (submode == 3) {
					
					if (pan_vx < 0) {
						pan_vx -= FlxG.elapsed * pan_ax;
						if (pan_vx >= 0) {
							submode = 4;
						}
					} else {
						pan_vx -= FlxG.elapsed * pan_ax;
						if (pan_vx <= 0) {
							submode = 4;
						}
					}
					if (pan_vy < 0) {
						pan_vy -= FlxG.elapsed * pan_ay;
						if (pan_vy >= 0) {
							pan_vy = 0;
						} 
					} else if (pan_vy > 0) {
						pan_vy -= FlxG.elapsed * pan_ay;
						if (pan_vy <= 0) {
							pan_vy = 0;
						}
					}
					
					FlxG.camera.scroll.x += FlxG.elapsed * pan_vx;
					FlxG.camera._scrollTarget.x += FlxG.elapsed * pan_vx;
					FlxG.camera.scroll.y += FlxG.elapsed * pan_vy;
					FlxG.camera._scrollTarget.y += FlxG.elapsed * pan_vy;
				} 
				
				if (submode == 4 || submode == 3) {
					var ct:Int = 0;
					if (pan_mvx >= 0) {
						if (FlxG.camera.scroll.x >= coord_list[0]) {
							FlxG.camera.scroll.x = coord_list[0];
							FlxG.camera._scrollTarget.x = coord_list[0];
							ct++;
						} else if (submode == 4) {
							FlxG.camera.scroll.x += 0.5;
							FlxG.camera._scrollTarget.x += 0.5;
						}
					} else  {
						if (FlxG.camera.scroll.x <= coord_list[0]) {
							FlxG.camera.scroll.x = coord_list[0];
							FlxG.camera._scrollTarget.x = coord_list[0];
							ct++;
						} else if (submode == 4) {
							FlxG.camera.scroll.x -= 0.5;
							FlxG.camera._scrollTarget.x -= 0.5;
						}
					}
					if (pan_mvy >= 0) {
						if (FlxG.camera.scroll.y >= coord_list[1]) {
							FlxG.camera.scroll.y = coord_list[1];
							FlxG.camera._scrollTarget.y = coord_list[1];
							ct++;
						} else if (submode == 4) {
							FlxG.camera.scroll.y += 0.5;
							FlxG.camera._scrollTarget.y += 0.5;
						}
					} else  {
						if (FlxG.camera.scroll.y <= coord_list[1]) {
							FlxG.camera.scroll.y = coord_list[1];
							FlxG.camera._scrollTarget.y = coord_list[1];
							ct++;
						} else if (submode == 4) {
							FlxG.camera.scroll.y -= 0.5;
							FlxG.camera._scrollTarget.y -= 0.5;
						}
					}
					if (ct == 2) {
						interp_mode = IMODE_INTERP;
						//submode = 0;
					}
				}
				
				//Log.trace([submode,pan_vx,pan_vy]);
				//coord_list = [pf(t[1]), pf(t[2]), pf(t[3])];
			} else if (interp_mode == IMODE_FADE) {
				fg_fade.alpha += fgfaderate;
				if (fgfaderate > 0 && fg_fade.alpha >= 1) {
					interp_mode = IMODE_INTERP;
				} else if (fgfaderate < 0 && fg_fade.alpha == 0) {
					interp_mode = IMODE_INTERP;
				}
				
			} else if (interp_mode == IMODE_FADE_A) {
				var c:Int = 0;
				for (i in 0...s_list.length) {
					s_list[i].alpha *= fgfaderate;
					if (fgfaderate < 1) {
						s_list[i].alpha -= 1 / 180.0;
						if (s_list[i].alpha <= 0) {
							c++;
						}
					} else {
						s_list[i].alpha += 1 / 180.0;
						if (s_list[i].alpha >= 1) {
							c++;
						}
					}
				}
				if (c == s_list.length) {
					interp_mode = IMODE_INTERP;
				}
			}else if (interp_mode == IMODE_FADE_SCALE) {
				var c:Int = 0;
				
				// fade_scale <varlist>  <xs1,ys1,rxs1,rys1...>
				for (i in 0...s_list.length) {
					if (s_list[i].scale.x < coord_list[i * 4]) {
						s_list[i].scale.x += coord_list[2 + i * 4];
						if (s_list[i].scale.x >= coord_list[i * 4]) {
							s_list[i].scale.x = coord_list[i * 4];
						}
					} else if (s_list[i].scale.x > coord_list[i * 4]) {
						s_list[i].scale.x -= coord_list[2 + i * 4];
						if (s_list[i].scale.x <= coord_list[i * 4]) {
							s_list[i].scale.x = coord_list[i * 4];
						}
					} else {
						c++;
					}
					if (s_list[i].scale.y < coord_list[1+i * 4]) {
						s_list[i].scale.y += coord_list[3 + i * 4];
						if (s_list[i].scale.y >= coord_list[1+i * 4]) {
							s_list[i].scale.y = coord_list[1+i * 4];
						}
					} else if (s_list[i].scale.y > coord_list[1+i * 4]) {
						s_list[i].scale.y -= coord_list[3 + i * 4];
						if (s_list[i].scale.y <= coord_list[1+i * 4]) {
							s_list[i].scale.y = coord_list[1+i * 4];
						}
					} else {
						c++;
					}
				}
				if (c == 2*s_list.length) {
					interp_mode = IMODE_INTERP;
					update_interp();
				}
			} else if (interp_mode == IMODE_WAIT) {
				fgfaderate -= FlxG.elapsed;
				if (R.input.jp_any()) {
					//if (fgfaderate > 0.5) {
						//fgfaderate = 0.5;
					//}
				}
				if (fgfaderate < 0) {
					interp_mode = IMODE_INTERP;
				}
			} else if (interp_mode == IMODE_D_BLOCK) {
				if (Std.is(sta,TestState)) {
					if (R.TEST_STATE.dialogue_box.is_active() == false) {
						interp_mode = IMODE_INTERP;
					}
				} else {
					if (R.TITLE_STATE.dialogue_box.is_active() == false) {
						interp_mode = IMODE_INTERP;
					}
				}
			} else if (interp_mode == IMODE_STOP_AT) {
				var c:Int = 0;
				for (i in 0...s_list.length) {
					var s:FlxSprite = s_list[i];
					if (s.x < coord_list[i * 2]) {
						if (s.x + FlxG.elapsed * s.velocity.x >= coord_list[i * 2]) {
							s.x = coord_list[i * 2];
							s.velocity.x = 0; // TODO mayeb allow this optionall
							s.acceleration.x = 0; // TODO mayeb allow this optionall
							c++;
						}
					} else if (s.x > coord_list[i * 2]) {
						if (s.x + FlxG.elapsed * s.velocity.x <= coord_list[i * 2]) {
							s.x = coord_list[i * 2];
							s.velocity.x = 0; // TODO mayeb allow this optionall
							s.acceleration.x = 0; // TODO mayeb allow this optionall
							c++;
						}
					} else {
						c++;
					}
					if (s.y < coord_list[1+i * 2]) {
						if (s.y + FlxG.elapsed * s.velocity.y >= coord_list[1+i * 2]) {
							s.y = coord_list[1+i * 2];
							s.velocity.y = 0; // TODO mayeb allow this optionall
							s.acceleration.y = 0; // TODO mayeb allow this optionall
							c++;
						}
					} else if (s.y > coord_list[1+i * 2]) {
						if (s.y + FlxG.elapsed * s.velocity.y <= coord_list[1+i * 2]) {
							s.y = coord_list[1+i * 2];
							s.velocity.y = 0; // TODO mayeb allow this optionall
							s.acceleration.y = 0; // TODO mayeb allow this optionall
							c++;
						}
					} else {
						c++;
					}
				}
				if (c == s_list.length * 2) {
					interp_mode  = IMODE_INTERP;
				}
			}
		} else if (mode == 2) {
		} else if (mode == 3) {
			mode = 0;
			exists = false;
			deactivate();
		}
		super.update(elapsed);
		
	}
	
}