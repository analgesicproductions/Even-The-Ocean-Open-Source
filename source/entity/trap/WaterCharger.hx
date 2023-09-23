package entity.trap;
/**
 * @author Copyright Melos Han-Tani, Developer of Analgesic Productions LLC, 2013 - ? , www.twitter.com/han_tani
 */
import entity.MySprite;
import entity.player.BubbleSpawner;
import flixel.addons.tile.FlxTilemapExt;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import global.C;
import haxe.Log;
import help.AnimImporter;
import help.HelpTilemap;
import help.HF;
import state.MyState;

class WaterCharger extends MySprite
{

	public var sparks:FlxTypedGroup<FlxSprite>;
	public static var ACTIVE_WaterChargers:List<WaterCharger>;
	public function new(_x:Float,_y:Float,_parent:MyState) 
	{
		sparks = new FlxTypedGroup<FlxSprite>();
		
		super(_x, _y, _parent, "WaterCharger");
	}
	
	public var valid_txs:Array<Int>;
	public var valid_tys:Array<Int>;
	public var valid_surface_txs:Array<Int>;
	public var valid_surface_tys:Array<Int>;
	public var xy_water_hash:Map < Int, Array<Int> > ;
	public var xy_surface_hash:Map < Int, Array<Int> > ;
	override public function change_visuals():Void 
	{
		switch (vistype) {
			case 0:
				AnimImporter.loadGraphic_from_data_with_id(this, 16, 16, "Pod", 1);
			case 1:
				AnimImporter.loadGraphic_from_data_with_id(this, 16, 16, "Pod", 0);
			default:
				AnimImporter.loadGraphic_from_data_with_id(this, 16, 16, "Pod", vistype);
		}
		animation.play("full", true);
		
		
		for (i in 0...props.get("nr_16")) {
			switch (vistype) {
				case 0:
					AnimImporter.loadGraphic_from_data_with_id(sparks.members[i], 16, 16, "WaterChargerSpark", "dark");
				case 1:
					AnimImporter.loadGraphic_from_data_with_id(sparks.members[i], 16, 16, "WaterChargerSpark", "light");
				default:
					AnimImporter.loadGraphic_from_data_with_id(sparks.members[i], 16, 16, "WaterChargerSpark", vistype);
			}
		}
		for (i in 0...props.get("nr_32")) {
			var j:Int = props.get("nr_16") + i;
			switch (vistype) {
				case 0:
					AnimImporter.loadGraphic_from_data_with_id(sparks.members[j], 32, 32, "WaterChargerSpark", "dark_big");
				case 1:
					AnimImporter.loadGraphic_from_data_with_id(sparks.members[j], 32, 32, "WaterChargerSpark", "light_big");
				default:
					AnimImporter.loadGraphic_from_data_with_id(sparks.members[j], 32, 32, "WaterChargerSpark", vistype+"_big");
			}
		}
	}
	
	override public function recv_message(message_type:String):Int 
	{
		// latr allow modding
		if (message_type == C.MSGTYPE_ENERGIZE_DARK) {
			if (dmgtype == 1) {
				vistype = dmgtype = 0;
				max_spark_allow = 1;
				change_visuals();
			}
		} else if (message_type == C.MSGTYPE_ENERGIZE_LIGHT) {
			if (dmgtype == 0) {
				vistype = dmgtype = 1;
				max_spark_allow = 1;
				change_visuals();
			} 
		}
		return 1;
	}
	
	override public function getDefaultProps():Map<String,Dynamic> 
	{
		var p:Map<String,Dynamic> = new Map<String,Dynamic>();
		p.set("vis-dmg", "0,0");
		p.set("nr_16", 2);
		p.set("nr_32", 1);
		p.set("tm_dmg", 0.05);
		p.set("layer", "bg1");
		p.set("spark_alpha", 1);
		p.set("spark_vel", 10);
		p.set("alpha_fade_out", 0.85);
		return p;
	}
	private var t_dmg:Float = 0;
	private var tm_dmg:Float = 0;
	private var alpha_fade_out:Float = 0.9;
	private var spark_vel:Float = 15;
	override public function set_properties(p:Map<String,Dynamic>):Void 
	{
		HF.copy_props(p, props);
		max_spark_allow = 1;
		dmgtype = Std.parseInt(props.get("vis-dmg").split(",")[1]);
		vistype = Std.parseInt(props.get("vis-dmg").split(",")[0]);
		tm_dmg = props.get("tm_dmg");
		sparks.clear();
		for (i in 0...props.get("nr_16")+props.get("nr_32")) {
			var s:FlxSprite = new FlxSprite();
			sparks.add(s);
		}
		change_visuals();
		spark_vel = props.get("spark_vel");
		alpha_fade_out = props.get("alpha_fade_out");
		sparks.setAll("alpha", props.get("spark_alpha"));
	}
	
	override public function destroy():Void 
	{
		ACTIVE_WaterChargers.remove(this);
		HF.remove_list_from_mysprite_layer(this, parent_state, [sparks]);
		super.destroy();
	}
	
	private var active_tm:FlxTilemapExt;
	override public function update(elapsed: Float):Void 
	{
		if (!did_init) {
			did_init = true;
			HF.add_list_to_mysprite_layer(this, parent_state, [sparks]);
			ACTIVE_WaterChargers.add(this);
			if (props.get("layer").toLowerCase() == "bg2") {
				init_water_arrays(parent_state.tm_bg2);
				active_tm = parent_state.tm_bg2;
			} else {
				init_water_arrays(parent_state.tm_bg);
				active_tm = parent_state.tm_bg;
			}
		}
		
		var tx:Int = Std.int((R.player.x + R.player.width / 2) / 16);
		var ty:Int = Std.int((R.player.y + R.player.height / 2) / 16);
		if (R.player.is_in_water() && xy_water_hash.exists(tx)) {
			if (HF.array_contains(xy_water_hash.get(tx), ty)) {
				t_dmg += FlxG.elapsed;
				if (t_dmg > tm_dmg) {
					t_dmg -= tm_dmg;
					if (BubbleSpawner.cur_bubble != null) {
						if (dmgtype == 1 && BubbleSpawner.cur_bubble_flavor == 0) {
							BubbleSpawner.force_pop();
						} else if (dmgtype == 0 && BubbleSpawner.cur_bubble_flavor == 1) {
							BubbleSpawner.force_pop();
						}
					} else {
						if (dmgtype == 0) {
							R.player.add_dark(1);
						} else {
							R.player.add_light(1);
						}
					}
				}
			}
		}
		super.update(elapsed);
	}
	
	
	public function pt_overlaps_tile(px:Float, py:Float, needed_dmgtype:Int = -1, surface:Bool = false ):Bool {
		if (needed_dmgtype != -1) {
			if (dmgtype != needed_dmgtype) {
				return false;
			}
		}
		var tx:Int = Std.int(px / 16);
		var ty:Int = Std.int(py / 16);
		if (!surface) {
			if (xy_water_hash.exists(tx)) {
				if (HF.array_contains(xy_water_hash.get(tx), ty)) { 
					return true;
				}
			}
		} else {
			if (xy_surface_hash.exists(tx)) {
				if (HF.array_contains(xy_surface_hash.get(tx), ty)) {
					return true;
				}
			}
		}
		return false;
	}
	
	private var t_init_spark_space:Float = 0;
	private var tm_init_spark_space:Float = 0.1;
	private var max_spark_allow:Int = 1;
	override public function draw():Void 
	{
		if (did_init) {
			
			if (max_spark_allow < sparks.length) {
				t_init_spark_space += FlxG.elapsed;
				if (t_init_spark_space > tm_init_spark_space) {
					t_init_spark_space = 0;
					max_spark_allow++;
				}
			}
			for (i in 0...sparks.length) {
				
				var j:Int = Std.int(valid_txs.length * Math.random());
				var s:FlxSprite = sparks.members[i];
				if (s.animation.finished) {
					s.alpha = 0;
					if (i < max_spark_allow) {
						if (s.width == 32) {
							s.animation.play("32_slash", true);
							s.angle = 90 * (Std.int(4 * Math.random()));
						} else {
							if (Math.random() > 0.5) {
								s.animation.play("16_slash",true);
							s.angle = 90 * (Std.int(4 * Math.random()));
							} else {
								s.animation.play("16_explosion", true);
								if (Math.random() > 0.5) {
									s.angle = 180;
								} else {
									s.angle = 90;
								}
							}
						}
						
						
						s.x = 16 * valid_txs[j];
						s.y = 16 * valid_tys[j];
						if (s.width == 32) {
							s.x -= 4;
							s.y -= 4;
						}
						HF.set_vel_vector(s.velocity, Std.int(s.angle), spark_vel);
						s.x -= 2;
						s.x += 4 * Math.random();
						s.y -= 2;
						s.y += 4 * Math.random();
						s.alpha = props.get("spark_alpha");
					}
				} else {
					s.alpha *= alpha_fade_out;
				}
			}
		}
		super.draw();
	}
	
	private var checked:Array<String>;
	private var checked_surface:Array<String>;
	private var queue:Array<String>;
	private function init_water_arrays(tmap:FlxTilemapExt):Void {
	
		xy_water_hash = new Map < Int, Array<Int> > ();
		xy_surface_hash = new Map < Int, Array<Int> > ();
		valid_surface_txs = [];
		valid_surface_tys = [];
		valid_txs = [];
		valid_tys = [];
		queue = [];
		var startstr:String = Std.string(Std.int(x / 16)) + "," + Std.string(Std.int(y / 16));
		queue.push(startstr);
		checked = [startstr];
		checked_surface = [];
		tmap = parent_state.tm_bg;
		
		while (queue.length > 0) {
			var next:String = queue.pop();
			var sx:Int = Std.parseInt(next.split(",")[0]);
			var sy:Int = Std.parseInt(next.split(",")[1]);
			var tile_id:Int;
			var might_push:String = "";
			if (sx + 1 < tmap.widthInTiles) {
				tile_id = tmap.getTile(sx + 1, sy);
				water_search_help(sx+1,sy,tile_id);
			}
			if (sx - 1 >= 0) {
				tile_id = tmap.getTile(sx -1, sy);
				water_search_help(sx - 1, sy, tile_id);
			}
			if (sy + 1 < tmap.heightInTiles) {
				tile_id = tmap.getTile(sx, sy+1);
				water_search_help(sx,sy+1, tile_id);
			}
			if (sy - 1 >= 0) {
				tile_id = tmap.getTile(sx , sy-1);
				water_search_help(sx,sy-1, tile_id);
			}
		}
		var coords_str:String = "";
		var start_x:Int = Std.int(x / 16);
		var start_y:Int  = Std.int(y / 16);
		for (i in 0...checked.length) {
			valid_txs.push(Std.parseInt(checked[i].split(",")[0]));
			valid_tys.push(Std.parseInt(checked[i].split(",")[1]));
			
			if (!xy_water_hash.exists(valid_txs[i])) {
				xy_water_hash.set(valid_txs[i], new Array<Int>());
			}
			var a:Array<Int> = xy_water_hash.get(valid_txs[i]);
			a.push(valid_tys[i]);
			xy_water_hash.set(valid_txs[i], a);
		}
		for (i in 0...checked_surface.length) {
			valid_surface_txs.push(Std.parseInt(checked_surface[i].split(",")[0]));
			valid_surface_tys.push(Std.parseInt(checked_surface[i].split(",")[1]));
			if (!xy_surface_hash.exists(valid_surface_txs[i])) {
				xy_surface_hash.set(valid_surface_txs[i], new Array<Int>());
			}
			var a:Array<Int> = xy_surface_hash.get(valid_surface_txs[i]);
			a.push(valid_surface_tys[i]);
			xy_surface_hash.set(valid_surface_txs[i], a);
		}
	}
	
	function water_search_help(sx:Int,sy:Int,tile_id:Int):Void 
	{
		if (HF.array_contains(HelpTilemap.active_water,tile_id) || HF.array_contains(HelpTilemap.active_surface_water,tile_id)) {
			var might_push:String = Std.string(sx) + "," + Std.string(sy);
			if (HF.array_contains(checked, might_push) == false && HF.array_contains(checked_surface,might_push) == false) {
				queue.push(might_push);	
				if (HF.array_contains( HelpTilemap.active_surface_water,tile_id)) {
					checked_surface.push(might_push);
				} else {
					checked.push(might_push);
				}
			}
		}
	}
}