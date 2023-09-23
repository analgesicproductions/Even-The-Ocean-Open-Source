package entity.npc;
import entity.MySprite;
import entity.util.RaiseWall;
import flash.geom.Point;
import flixel.FlxObject;
import global.C;
import haxe.Log;
import help.AnimImporter;
import help.FlxX;
import help.HF;
import flixel.FlxG;
import flixel.FlxSprite;
import state.MyState;
import flixel.group.FlxGroup;
/**
 * @author Copyright Melos Han-Tani, Developer of Analgesic Productions LLC, 2013 - ? , www.twitter.com/han_tani
 */
class WirePoint extends MySprite
{

	private var glow:FlxSprite;
	private var raisewallChild:Bool = false;
	public function new(_x:Float,_y:Float,_parent:MyState) 
	{
		glow = new FlxSprite();
		super(_x, _y, _parent, "WirePoint");
	}
	
	
	private var forceTargetDir:Int = -1;
	override public function change_visuals():Void 
	{
		vistype = 0;
		AnimImporter.loadGraphic_from_data_with_id(this, 16, 16,"WirePoint",vistype);
		AnimImporter.loadGraphic_from_data_with_id(glow, 16, 16, "WirePoint", "glow" + Std.string(vistype));
		animation.play("cap");
		glow.animation.play("lcap");
	}
	
	override public function getDefaultProps():Map<String,Dynamic> 
	{
		var p:Map<String,Dynamic> = new Map<String,Dynamic>();
		p.set("vistype", 0);
		p.set("pos", "0,16");
		p.set("children", "");
		p.set("forceTargetDir", -1);
		return p;
	}
	
	private var pts:Array<Point>;
	override public function set_properties(p:Map<String,Dynamic>):Void 
	{
		HF.copy_props(p, props);
		vistype = props.get("vistype");
		pts = HF.string_to_point_array(cast props.get("pos"));
		forceTargetDir = props.get("forceTargetDir");
		change_visuals();
	}
	
	override public function destroy():Void 
	{
		HF.remove_list_from_mysprite_layer(this, parent_state, [glow]);
		super.destroy();
	}
	
	private var t_animate:Float = 0;
	
	private var is_on:Bool = false;
	private var child:MySprite;
	private var main_suffix:String = "ud";
	
	// Doesn't actually convey energy, but used to determine cap rotations
	private var sourceDir:Int = 0;
	private var targetDir:Int = 0;
	override public function update(elapsed: Float):Void 
	{
		if (!did_init) {
			did_init = true;
			populate_parent_child_from_props();
			HF.add_list_to_mysprite_layer(this, parent_state, [glow]);
			if (children.length > 0 && Std.is(children[0], RaiseWall)) {
				raisewallChild = true;
			}
		}
		
		if (glow.animation.curAnim  != null) {
			fTimer += elapsed;
			if (fTimer > 1.0 / glow.animation.curAnim.frameRate ) {
				fTimer -= 1.0 / glow.animation.curAnim.frameRate;
				fIdx ++;
				if (fIdx >= glow.animation.curAnim.numFrames) {
					fIdx = 0;
				}
			}
		}
	
		
		var dirs:Int = 0;
		for (parent in parents) {
			if (parent != null) {
				if (parent.x < x) {
					sourceDir = FlxObject.LEFT;
				} else if (parent.y < y) {
					sourceDir = FlxObject.UP;
				} else if (parent.x > x) {
					sourceDir = FlxObject.RIGHT;
				} else {
					sourceDir = FlxObject.DOWN;
				}
			}
		}
		for (child in children) {
			if (child != null) {
				var endX:Float = ix+ pts[pts.length - 1].x;
				var endY:Float = iy+ pts[pts.length - 1].y;
				if (child.x +child.width < endX) {
					targetDir =FlxObject.LEFT;
					//Log.trace("l");
				} else if (child.y < endY) {
					targetDir = FlxObject.UP;
					//Log.trace("u");
				} else if (child.x > endX) {
					targetDir = FlxObject.RIGHT;
					//Log.trace("r");
				} else {
					targetDir = FlxObject.DOWN;
					//Log.trace("down");
				}
				
			}
			if (forceTargetDir >= 0 && forceTargetDir <= 3) {
				if (forceTargetDir == 0) targetDir = FlxObject.UP;
				if (forceTargetDir == 1) targetDir = FlxObject.RIGHT;
				if (forceTargetDir == 2) targetDir = FlxObject.DOWN;
				if (forceTargetDir == 3) targetDir = FlxObject.LEFT;
			}
		}
		
		if (t_animate > 0) {
			t_animate -= elapsed;
			if (t_animate < 0) {
				energyPrefix = "";
			}
		}
		//Log.trace([glow.alpha, glow.visible]);
		
		
		var ox:Float = x;
		var oy:Float = y;
		if (move_mode == 0) {
			if (R.editor.editor_active && FlxG.mouse.justPressed) {
				for (i in 0...pts.length) {
					move(ix + pts[i].x, iy + pts[i].y);
					if (FlxG.mouse.inside(this)) {
						// ALT+Click on last point = add new point
						if (FlxG.keys.pressed.SHIFT && i == pts.length-1) {
							moving_idx = pts.length;
							pts.push(new Point(0, 0));
							move_mode = 1;
							break;
						} else if (FlxG.keys.pressed.D) {
							pts.splice(i, 1);
							//Log.trace("remove " + Std.string(i));
							props.set("pos", HF.point_array_to_string(pts));
							break;
						} else {
							move_mode = 1;
							moving_idx = i;
							break;
						}
					}
				}
			}
		} else if (move_mode == 1) {
			// Move the box to the mouse's position, but round it to 16.
			move(FlxG.mouse.x, FlxG.mouse.y);
			HF.round_to_16(this);
			HF.round_to_16(this, false);
			// update pts to save to props
			pts[moving_idx].x = x - ix;
			pts[moving_idx].y = y - iy;
			if (FlxG.mouse.justPressed) {
				props.set("pos", HF.point_array_to_string(pts));
				move_mode = 0;
			}
			
		}
		x = ox;
		y = oy;
		
		
		super.update(elapsed);
	}
	
	private var moving_idx:Int = 0;
	private var move_mode:Int = 0;
	override public function draw():Void 
	{
		
		var ox:Float = x;
		var oy:Float = y;
		
		// draw initial 'straight' bit below the cap
		switch (sourceDir) {
			case FlxObject.UP: angle = 180;
			case FlxObject.RIGHT: angle = 270;
			case FlxObject.DOWN: angle = 0;
			case FlxObject.LEFT: angle = 90;
		}
		animHelp("straight");
		drawHelp();

		var ed:Bool = R.editor.editor_active; 
		R.editor.editor_active = false; // turn off child drawing too many red lines
		for (i in 0...pts.length) {
			if (move_mode != 0) {
				move(ix + pts[i].x, iy + pts[i].y);
				drawHelp();
				continue;
			}
			var safety:Int = 30;
			while (true || safety > 0) {
				angle = 0; // reset angle, it'll be set in code
				safety--;
				var hor:Bool = false;
				// "move" towards the next pt, drawing segments one by one
				if (x < ix + pts[i].x) {
					x += 16;
					hor = true;
				} else if (x > ix + pts[i].x) {
					x -= 16;
					hor = true;
				} else if (y < iy + pts[i].y) {
					y += 16;
				} else if (y > iy + pts[i].y) {
					y -= 16;
				} else {
					break;
				}
				// Drwaing the end segment - draw a straight bit and a cap
				if (i == pts.length -1 && x == ix+ pts[i].x && y == iy + pts[i].y) {
					animHelp("straight");
					switch (targetDir) {
						case FlxObject.UP: angle = 0;
						case FlxObject.RIGHT: angle = 90;
						case FlxObject.DOWN: angle = 180;
						case FlxObject.LEFT: angle = 270;
					}
					// dont draw final cap if raisewall child bc of the annoying stuff with that
					if (!(raisewallChild && forceTargetDir > -1)) drawHelp();
					animHelp("cap");
					if (!(raisewallChild && forceTargetDir > -1)) drawHelp();
					if (raisewallChild) {
						switch (targetDir) {
							case FlxObject.UP: y += 16; drawHelp(); y -= 16;
							case FlxObject.RIGHT: x -= 16; drawHelp(); x += 16;
							case FlxObject.DOWN: y -= 16; drawHelp(); y += 16;
							case FlxObject.LEFT: x += 16; drawHelp(); x -= 16;
						}
					}
				// Reached a corner peace so draw it based on the flow
				} else if (x == ix + pts[i].x && y == iy + pts[i].y) {
					var drawDir:Int = 0;
					var dirA:Int = 0; // entrance
					var dirB:Int = 0; // exit
					if (i == 0) {
						dirA |= sourceDir; // The first turn will have one of its ends facig the 'source'.
					} else {
						// Find the 'entrance' of the corner pipe
						if (pts[i - 1].y < pts[i].y) {
							dirA |= FlxObject.UP;
						} else if (pts[i-1].y > pts[i].y) {
							dirA |= FlxObject.DOWN;
						} else if (pts[i - 1].x < pts[i].x) {
							dirA |= FlxObject.LEFT;
						} else if (pts[i-1].x > pts[i].x) {
							dirA |= FlxObject.RIGHT;
						}
					}
					// Find the destination of the corner pipe
					if (pts[i + 1].y < pts[i].y) {
						dirB |= FlxObject.UP;
					} else if (pts[i+1].y > pts[i].y) {
						dirB |= FlxObject.DOWN;
					} else if (pts[i + 1].x < pts[i].x) {
						dirB |= FlxObject.LEFT;
					} else if (pts[i+1].x > pts[i].x) {
						dirB |= FlxObject.RIGHT;
					}
					// based on the flow of the pipe, possibly play the 'reverse' animaton so fllow looks right
					drawDir = dirA | dirB;
					if (drawDir == FlxObject.RIGHT | FlxObject.DOWN) angle = 0;
					if (drawDir == FlxObject.LEFT | FlxObject.DOWN) angle = 90;
					if (drawDir == FlxObject.LEFT | FlxObject.UP) angle = 180;
					if (drawDir == FlxObject.RIGHT | FlxObject.UP) angle = 270;
					
					var rev:String = "";
					// might jus tneed to change scale and use a diff angle
					if (angle == 0 && dirA == FlxObject.RIGHT) rev = "reverse";
					if (angle == 90 && dirA == FlxObject.DOWN) rev = "reverse";
					if (angle == 180 && dirA == FlxObject.LEFT) rev = "reverse";
					if (angle == 270 && dirA == FlxObject.UP) rev = "reverse";
					animHelp("turn"+rev);
					drawHelp();
					
				} else { // staright part
					animHelp("straight");
					// figure out flow based on the straight pipe being hor/ert, and if it's near the first part of the wire
					if (hor) {
						if (i == 0) {
							if (ix < x) { angle = 90; }
							else { angle = 270; }
						} else {
							if (pts[i - 1].x < pts[i].x) { angle = 90; }
							else { angle = 270; }
						}
					} else {
						if (i == 0) {
							if (iy < y) { angle = 180; }
							else { angle = 0; }
						} else {
							if (pts[i - 1].y < pts[i].y) { angle = 180; }
							else { angle = 0; }
						}
					}
					drawHelp();
				}
			}
		}
		angle = 0;
		R.editor.editor_active = ed;
		x = ox;
		y = oy;
		
		// Draw cap on top
		switch (sourceDir) {
			case FlxObject.UP: angle = 0;
			case FlxObject.RIGHT: angle = 90;
			case FlxObject.DOWN: angle = 180;
			case FlxObject.LEFT: angle = 270;
		}
		animHelp("cap");
		drawHelp();
	}
	
	private function animHelp(nam:String):Void {
		if (t_animate > 0 && energyPrefix != "" ) {
			if (t_animate > 1) {
				glow.alpha = 1 - ((t_animate - 1) / (1.25 - 1));
			} else if (t_animate > 0.8) {
				glow.alpha = 1;
			} else {
				glow.alpha = t_animate / 0.8;
			}
			glow.animation.play(energyPrefix + nam,true,false,fIdx);
		} else {
			glow.alpha = 0;
		}
		animation.play(nam);
		
	}
	
	var fIdx:Int = 0;
	var fTimer:Float = 0;
	private function drawHelp():Void {
		super.draw();
		glow.angle = angle;
		glow.move(x, y);
		glow.draw();
	}
	
	private var energyPrefix:String = "";
	override public function recv_message(message_type:String):Int 
	{
		//if (message_type == "button_off") {
			//return -1;
		//} else if (message_type == "button_on") {
			//return 69;
		//}
		switch (message_type) {
			case C.MSGTYPE_ENERGIZE_DARK:
				energyPrefix = "d";
			case C.MSGTYPE_ENERGIZE_LIGHT:
				energyPrefix = "l";
			case C.MSGTYPE_ENERGIZE_TICK_DARK:
				energyPrefix = "d";
			case C.MSGTYPE_ENERGIZE_TICK_LIGHT:
				energyPrefix = "l";
		}
		if (energyPrefix != "") {
				if (t_animate <= 0 || t_animate > 1) {
					if (t_animate <= 0) {
						t_animate = 1.25;
					}
				} else {
					t_animate = 1;
				}
		}
		
		return C.RECV_STATUS_OK;
	}
}