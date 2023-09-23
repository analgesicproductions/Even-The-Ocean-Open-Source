package help;
import entity.MySprite;
import entity.npc.SetPiece;
import entity.tool.CameraTrigger;
import entity.util.LineCollider;
import entity.util.NewCamTrig;
import entity.util.WalkBlock;
import flash.display.BitmapData;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.utils.ByteArray;
import flixel.addons.tile.FlxTilemapExt;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import global.C;
import haxe.Log;
import openfl.Assets;
import openfl.display.BlendMode;
import openfl.display.PNGEncoderOptions;
import openfl.display.Sprite;
import state.TestState;
import sys.FileSystem;
import sys.io.File;
import sys.io.FileOutput;

/**
 * ...
 * @author Copyright Melos Han-Tani, Developer of Analgesic Productions LLC, 2013 - ? , www.twitter.com/han_tani
 */
class MapPrinter
{
		public static function eto_print_png(cur_state:TestState, tileset_tile_width:Int = 20, photograph_name:String = "", tbitmap:BitmapData):Void {
			
			var is_photo:Bool = false;
			if (photograph_name != "") is_photo = true;
			Log.trace("taking photo");
			#if cpp
			
			var bm:BitmapData = new BitmapData(cur_state.tm_bg.widthInTiles*16, cur_state.tm_bg.heightInTiles*16, true, 0xff0000);
			//var tileset:BitmapData = cur_state.tm_bg.graphic.bitmap;
			var tileset:BitmapData = tbitmap;
			
			// not sure if i need this
			var atileset:BitmapData = new BitmapData(tileset.width, tileset.height,true, 0x00000000);
			atileset.copyPixels(tileset, new Rectangle(0, 0, tileset.width, tileset.height), new Point(0, 0));
			
			var tileset_rect:Rectangle = new Rectangle();
			var dest_pt:Point = new Point();
			var drawables:Array<Dynamic> =  [cur_state.b_bg_parallax_layers,cur_state.particle_system.bg_draw_layer,cur_state.below_bg_sprites, cur_state.bg_parallax_layers,cur_state.tm_bg, cur_state.bg1_sprites, cur_state.tm_bg2, cur_state.bg2_sprites,cur_state.player, cur_state.fg1_parallax_layers,cur_state.tm_fg, cur_state.fg2_sprites, cur_state.fg2_parallax_layers,cur_state.tm_fg2,cur_state.particle_system.fg_draw_layer];
			
			
			var invishard_tileset:BitmapData = Assets.getBitmapData("assets/tileset/invishard.png");
			
			for (o in drawables) {
				if (Std.is(o, FlxTilemapExt)) {
					tileset_rect.width = tileset_rect.height = 16;
					var t:FlxTilemapExt = cast o;
					var tilesetwidthintiles:Int = t.widthInTiles;
					var _data:Array<Int> = t._data;
					for (iy in 0...t.heightInTiles) {
						for (ix in 0...t.widthInTiles) {
							var tid:Int = _data[iy * tilesetwidthintiles + ix];
							if (tid == 0) continue;
							if (is_photo && HF.array_contains(HelpTilemap.invishard, tid)) continue;
							if (HelpTilemap.invis_id_to_frame.exists(tid)) {
								tid = HelpTilemap.invis_id_to_frame.get(tid);
								tileset_rect.x = 16 * (tid % 10);
								tileset_rect.y = 16 * Std.int(tid / 10);
								dest_pt.x = ix * 16; dest_pt.y = iy * 16;
								bm.copyPixels(invishard_tileset, tileset_rect, dest_pt, atileset, dest_pt, true);
							} else {
								tileset_rect.x = 16 * (tid % tileset_tile_width);
								tileset_rect.y = 16 * Std.int(tid / tileset_tile_width);
								dest_pt.x = ix * 16; dest_pt.y = iy * 16;
								bm.copyPixels(tileset, tileset_rect, dest_pt, atileset, dest_pt, true);
							}
						}
					}
				} else if (Std.is(o, FlxGroup)) {
					var g:FlxGroup = cast o;
					var m:Matrix = new Matrix(1, 0, 0, 1);
					
					for (s in g.members) {
						if (s != null) {
							var treat_as_flxsprite:Bool = false;
							if (Std.is(s, SetPiece)) treat_as_flxsprite = true;
							
							if (!treat_as_flxsprite && Std.is(s, MySprite)) {
								
								if (Std.is(s, CameraTrigger)) {
									bm = draw_camera_trigger(bm, m, cast s);
								} else if (Std.is(s, NewCamTrig)) {
									bm = draw_newcamtrig(bm, m, cast s);
								} else if (Std.is(s, LineCollider)) {
									bm = draw_linecollider(bm, m, cast s);
								} else if (Std.is(s, WalkBlock)) {
									bm = draw_walkblock(bm, m, cast s);	
								} else {
									var ms:MySprite = cast s;
									m.tx = ms.ix;
									m.ty = ms.iy;
									bm.draw(ms.updateFramePixels(), m);
								}
							} else if (Std.is(s, FlxSprite) && is_photo) {
								var fs:FlxSprite = cast s;
								if (fs.visible && fs.alpha> 0 && fs.exists) {
									m.tx = FlxG.camera.scroll.x - (FlxG.camera.scroll.x  * fs.scrollFactor.x);
									m.ty = FlxG.camera.scroll.y * (1 - fs.scrollFactor.y);
									m.tx += fs.x * fs.scrollFactor.x;
									m.ty += fs.y * fs.scrollFactor.y;
									var tbm:BitmapData = fs.updateFramePixels();
									var colortrans:ColorTransform = new ColorTransform(1, 1, 1, fs.alpha);
									if (tbm  != null) {
										if (fs.blend == BlendMode.ADD || fs.blend == BlendMode.SCREEN || fs.blend == BlendMode.MULTIPLY) {
											renderBlend(bm, tbm,fs,m);
										} else {
											bm.draw(tbm, m, colortrans);
										}
									}
								}
							} else if (Std.is(s, FlxGroup) && is_photo) {
								var otherGroup:FlxGroup = cast s;
								for (_m in otherGroup.members) {
									if (_m != null) {
										var ss:FlxSprite = cast _m;
										m.tx = FlxG.camera.scroll.x - (FlxG.camera.scroll.x  * ss.scrollFactor.x);
										m.ty = FlxG.camera.scroll.y * (1 - ss.scrollFactor.y);
										m.tx += ss.x * ss.scrollFactor.x;
										m.ty += ss.y * ss.scrollFactor.y;
										var tbm:BitmapData = ss.updateFramePixels();
										var colortrans:ColorTransform = new ColorTransform(1, 1, 1, ss.alpha);
										if (tbm  != null) {
											if (ss.blend == BlendMode.ADD || ss.blend == BlendMode.SCREEN || ss.blend == BlendMode.MULTIPLY) {
												renderBlend(bm, tbm,ss,m);
											} else {
												bm.draw(tbm, m, colortrans);
											}
										}
									}
								}
							}
						}
					}
				}
			}
			
			if (photograph_name != "") {
				var nbm:BitmapData = null;
				//nbm = new BitmapData(cur_state.tm_bg.widthInTiles*16, cur_state.tm_bg.heightInTiles*16, true, 0xff0000);
				nbm = new BitmapData(26 * 16, 16 * 16, true, 0xff0000);
				dest_pt.x = 0;
				dest_pt.y = 0;
				tileset_rect.width = 26 * 16;
				tileset_rect.height = 16 * 16;
				tileset_rect.x = Std.int(FlxG.camera.scroll.x);
				tileset_rect.y = Std.int(FlxG.camera.scroll.y);
				nbm.copyPixels(bm, tileset_rect, dest_pt);
				bm = nbm;
			}
			
			var b:ByteArray = null;
			#if openfl_legacy
			b = bm.encode("png", 1);
			#else
			b = bm.encode(bm.rect, new PNGEncoderOptions());
			#end
			var name:String = cur_state.MAP_NAME + ".png";
			
			var dir:String = C.EXT_NONCRYPTASSETS + "pngexports/";
			
			
			if (FileSystem.exists("photographs/") == false) {
				FileSystem.createDirectory("photographs/");
			}
			
			if (FileSystem.exists(C.EXT_NONCRYPTASSETS) == false) {
				FileSystem.createDirectory(C.EXT_NONCRYPTASSETS);
			}
			
			if (FileSystem.exists(C.EXT_NONCRYPTASSETS + "pngexports/") == false) {
				FileSystem.createDirectory(C.EXT_NONCRYPTASSETS + "pngexports/");
			}
			
			if (photograph_name != "") {
				dir = "photographs/";
				name = photograph_name + ".png";
			}
			Log.trace(dir + name);
			var fo:FileOutput = File.write(dir+name, true);
			fo.writeString(b.toString());
			fo.close();
			#end
		}
		private static function draw_linecollider(bm:BitmapData, m:Matrix, lc:LineCollider):BitmapData {
			var s:Sprite = new Sprite();
			s.graphics.lineStyle(1, 0xff0000, 1);
			//Log.trace("hi");
			for (i in 0...lc.pts.length) {
				if (i == lc.pts.length - 1) break;
				s.graphics.moveTo(lc.ix + lc.pts[i].x, lc.iy + lc.pts[i].y);
				s.graphics.lineTo(lc.ix + lc.pts[i+1].x, lc.iy + lc.pts[i+1].y);
			}
			bm.draw(s);
			return bm;
		}
		
		private static function draw_newcamtrig(bm:BitmapData, m:Matrix, ct:NewCamTrig):BitmapData {

			
			var tw:Int = Std.int(16 *  ct.props.get("tile_w"));
			var th:Int = Std.int(16 *  ct.props.get("tile_h"));
			//Log.trace([tw, th]);
			bm.fillRect(new Rectangle(ct.ix, ct.iy, tw, 1), 0xffff0000);
			bm.fillRect(new Rectangle(ct.ix, ct.iy+th, tw, 1), 0xffff0000);
			bm.fillRect(new Rectangle(ct.ix, ct.iy, 1,th), 0xffff0000);
			bm.fillRect(new Rectangle(ct.ix+tw, ct.iy, 1,th), 0xffff0000);
			
			//draw_rect(ct.ix, ct.iy, tw, 1, bm);
			
			return bm;
		}
		
		private static function draw_walkblock(bm:BitmapData, m:Matrix, ct:WalkBlock):BitmapData {

			
			var tw:Int = Std.int(16 *  Std.parseInt(ct.props.get("w,h").split(",")[0]));
			var th:Int = Std.int(16 *  Std.parseInt(ct.props.get("w,h").split(",")[1]));
			bm.fillRect(new Rectangle(ct.ix, ct.iy, tw, th), 0xff777777);
			return bm;
		}
		
		private static function draw_rect(_x:Int, _y:Int, w:Int,h:Int, bm:BitmapData):Void {
			for (i in 0...h) {
				for (j in 0...w) {
					bm.setPixel32(_x + j, _y + i, 0xffff0000);
				}
			}
		}
		private static function draw_camera_trigger(bm:BitmapData,m:Matrix, ct:CameraTrigger):BitmapData {
			var tr:FlxSprite = cast Reflect.getProperty(ct, "trigger_region");
			var enters:FlxGroup = cast Reflect.getProperty(ct, "enter_triggers");
			var exits:FlxGroup = cast Reflect.getProperty(ct, "exit_triggers");
			
			m.tx = tr.x;
			m.ty = tr.y;
			bm.draw(tr.updateFramePixels(), m);
			
			for (d in [enters,exits]) {
				for (i in 0...d.length) {
					if (d.members[i] != null) {
						var s:FlxSprite = cast d.members[i];
						m.tx = s.x;
						m.ty = s.y;
						bm.draw(s.updateFramePixels(), m);
					}
				}
			}
			return bm;
			
		}
		
		private static function renderBlend(bm:BitmapData,tbm:BitmapData,fs:FlxSprite,m:Matrix):Void {
		var start_x:Int = Std.int(FlxG.camera.scroll.x);
		var start_y:Int = Std.int(FlxG.camera.scroll.y);
		var grab_x:Int = 0;
		var grab_y:Int = 0;
		for (i in start_y...start_y + 256) {
			for (j in start_x...start_x + 416) {
				grab_x = Std.int(j - m.tx);
				grab_y = Std.int(i - m.ty);
				if (grab_x >= 0 && grab_y >= 0 && grab_x < tbm.width && grab_y < tbm.height) {
					var rgb:Int = tbm.getPixel(grab_x, grab_y);
					var red:Int = rgb & 0xff0000;
					var green:Int = rgb & 0x00ff00;
					var blue:Int = rgb & 0x0000ff;
					var bm_rgb:Int = bm.getPixel(j, i);
					var bm_red:Int = bm_rgb & 0xff0000;
					var bm_green:Int = bm_rgb & 0x00ff00;
					var bm_blue:Int = bm_rgb & 0x0000ff;
					
					if (fs.blend == BlendMode.ADD) {
						red += bm_red;
						if (red > 0xff0000) {
							red = 0xff0000;
						}
						green += bm_green;
						if (green > 0xff00) {
							green = 0xff00;
						}
						blue += bm_blue;
						if (blue > 0xff) {
							blue = 0xff;
						}
						bm.setPixel(j, i, red + green + blue);
					} else if (fs.blend == BlendMode.MULTIPLY) {
						red = Std.int(255 * (((red >> 16) / (255.0)) * ((bm_red >> 16) / (255.0))));
						green = Std.int(255 * (((green >> 8) / (255.0)) * ((bm_green >> 8) / (255.0))));
						blue = Std.int(255 * (((blue) / (255.0)) * ((bm_blue >> 0) / (255.0))));
						
						red <<= 16;
						green <<= 8;
						bm.setPixel(j, i, red + green + blue);
					}  else {
						// 1 - (1-a)(1-b)
						red = Std.int(255 * (1.0 - (1.0 - (red >> 16) / (255.0)) * (1.0 - (bm_red >> 16) / (255.0))));
						green = Std.int(255 * (1.0 - (1.0 - (green >> 8) / (255.0)) * (1.0 - (bm_green >> 8) / (255.0))));
						blue = Std.int(255 * (1.0 - (1.0 - (blue) / (255.0)) * (1.0 - (bm_blue) / (255.0))));
						red <<= 16;
						green <<= 8;
						bm.setPixel(j, i, red + green + blue);
					}
				}
			}
		}
	}
		
}