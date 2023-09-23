package entity.trap;
import entity.MySprite;
import haxe.Log;
import help.AnimImporter;
import help.HelpTilemap;
import help.HF;
import hscript.Expr;
import hscript.Interp;
import openfl.Assets;
import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import state.MyState;

/**
 * @author Copyright Melos Han-Tani, Developer of Analgesic Productions LLC, 2013 - ? , www.twitter.com/han_tani
 */
class WaterShooter extends MySprite
{

	private var expr:Expr;
	private var interp:Interp;
	private var bullets:FlxTypedGroup<FlxSprite>;
	private var num_bullets:Int = 0;
	private var max_bullet_vel:Int = 0;
	
	private var mode:Int = 0;
	private var MODE_IDLE:Int = 0;
	private var MODE_CHARGE:Int = 1;
	private var MODE_SHOOT:Int = 2;
	
	private var t_idle:Float = 0;
	private var tm_idle:Float = 2;
	private var t_charge:Float = 0;
	private var tm_charge:Float = 1;
	
	private var particles:FlxTypedGroup<FlxSprite>;
	private var particles_per_bullet:Int = 4;
	
	public function new(_x:Float,_y:Float,_parent:MyState) 
	{
		super(_x, _y, _parent, "WaterShooter");
		interp = new Interp();
		interp.variables.set("this", this);
		interp.variables.set("R", R);
		interp.variables.set("FlxG", FlxG);
	}
	
	override public function getDefaultProps():Map<String,Dynamic> 
	{
		var p:Map<String,Dynamic> = new Map<String,Dynamic>();
		p.set("vistype", 0);
		p.set("num_bullets", 1 );
		p.set("max_bullet_vel", -300);
		p.set("tm_idle", 0);
		p.set("tm_charge", 0);
		p.set("tm_init", 0);
		p.set("bul_vel_scale", 1);
		//p.set("script_path", "trap/WaterShooter_hs.hx");
		return p;
	}
	
	private var t_init:Float = 0;
	private var tm_init:Float = 0;
	private var bul_vel_scale:Float = 1;
	override public function set_properties(p:Map<String,Dynamic>):Void 
	{
		HF.copy_props(p, props);
		vistype = props.get("vistype");
		max_bullet_vel = props.get("max_bullet_vel");
		num_bullets = props.get("num_bullets");
		tm_idle = props.get("tm_idle");
		tm_charge = props.get("tm_charge");
		tm_init = props.get("tm_init");
		bul_vel_scale = props.get("bul_vel_scale");
		if (bullets != null) {
			bullets.callAll("destroy"); bullets.clear();
		}
		if (bullets == null) {
			particles = new FlxTypedGroup<FlxSprite>();
			bullets = new FlxTypedGroup<FlxSprite>();
		}
		
		bullets.maxSize = num_bullets;
		particles.maxSize = num_bullets * particles_per_bullet;
		for (i in 0...num_bullets) {
			var a_bullet:FlxSprite = new FlxSprite();
			AnimImporter.loadGraphic_from_data_with_id(a_bullet, 48, 32, name + "Bullet",Std.string(vistype));
			bullets.add(a_bullet);
			a_bullet.width = 32; a_bullet.offset.set(8, 0);
			a_bullet.exists = false;
			for (j in 0...particles_per_bullet) {
				var particle:FlxSprite = new FlxSprite();
				AnimImporter.loadGraphic_from_data_with_id(particle, 8, 8, name + "Bullet", "particle");
				particles.add(particle);
				particle.exists = false;
			}
		}
		
		
		// idle warn fire (all looped)
			//expr = HF.get_program_from_script_wrapper(props.get("script_path"));
		AnimImporter.loadGraphic_from_data_with_id(this, 32, 16, name, Std.string(vistype));
		animation.play("idle");
	}
	
	override public function destroy():Void 
	{
		HF.remove_list_from_mysprite_layer(this, parent_state, [particles,bullets]);
		super.destroy();
	}
	
	private var boost_ticks:Int = 0;
	override public function update(elapsed: Float):Void 
	{
		if (!did_init) {
			did_init = true;
			HF.add_list_to_mysprite_layer(this, parent_state, [particles,bullets]);
		}
		//interp.execute(expr);
		if (t_init < tm_init) {
			t_init += FlxG.elapsed;
			super.update(elapsed);
			return;
		}
		
		if (this.mode == this.MODE_IDLE) {
			this.t_idle += FlxG.elapsed;
			if (this.t_idle  > this.tm_idle) {
				this.t_idle = 0;
				this.mode = this.MODE_CHARGE;
				this.animation.play("warn");
			}
		} else if (this.mode == this.MODE_CHARGE){
			this.t_charge += FlxG.elapsed;
			if (this.t_charge > this.tm_charge) {
				this.t_charge = 0;
				this.mode = this.MODE_SHOOT;
				this.animation.play("fire");
				
				var i:Int = 0;
				for (bullet in this.bullets.members) {
					if (bullet != null) {
						bullet.animation.play("up");
						bullet.exists = true;
						bullet.x = this.x;
						bullet.y = this.y;
						bullet.velocity.y = this.max_bullet_vel * ((1.0 * (i + 1)) / this.num_bullets);
						if (i != bullets.length-1) {
							bullet.velocity.y *= bul_vel_scale;
							
						}
						bullet.velocity.x = 0;
						bullet.acceleration.y = 250;
						bullet.alpha = 1;
						bullet.ID = 0;
						
						for (j in (i * particles_per_bullet)...((i + 1) * particles_per_bullet)) {
							particles.members[j].exists = true;
							particles.members[j].x = bullet.x - (particles.members[j].width / 2) + (bullet.width / 2);
							particles.members[j].y = bullet.y + bullet.height - particles.members[j].height / 2;
							particles.members[j].velocity.set( -20 + 40 * Math.random(), bullet.velocity.y - 30);
							particles.members[j].acceleration.y = 260 + 50 * Math.random();
							particles.members[j].animation.play("idle");
						}
					}
					i++;
				}
			}
			
			boost_ticks --;
			if (R.input.jpA1) {
				boost_ticks = 10;
			}
		} else if (this.mode == this.MODE_SHOOT) {
			var nr_exist:Int = 0;
			var biggest_boost:Float = 0;
			if (boost_ticks > 0) boost_ticks --;
			
			for (bullet in this.bullets.members) {
				if (bullet != null && bullet.exists) {
					if (bullet.overlaps(R.player) && bullet.velocity.y < 0) {
						if (bullet.velocity.y < biggest_boost) {
							biggest_boost = bullet.velocity.y;
						}
					}
					
					if (bullet.ID == 1 && bullet.animation.finished) {
						bullet.exists = false;
						continue;
					}
					
					if (bullet.velocity.y > -30) {
						if (bullet.animation.curAnim != null) {
							if (bullet.animation.curAnim.name == "up") {
								bullet.animation.play("switch_dir");
							} else if (bullet.animation.curAnim.name == "switch_dir") {
								bullet.ID = 1;
								bullet.alpha -= 0.03;
							} else if (bullet.animation.curAnim.name == "down") {
								bullet.alpha -= 0.09;
							}
						} else if (bullet.ID == 1) {
							bullet.animation.play("down");
						}
					} 
					
					var tid:Int = parent_state.tm_bg.getTileID(bullet.x + bullet.width / 2, bullet.y);
					if (HF.array_contains(HelpTilemap.permeable,tid) == false) {
						FlxObject.separate(bullet, parent_state.tm_bg);
					}
					if (bullet.touching == FlxObject.UP) {
						bullet.velocity.y = 1;
						bullet.animation.play("switch_dir");
						nr_exist++;
					} else if (bullet.touching == FlxObject.DOWN) {
						bullet.exists = false;
					} else {
						nr_exist ++;
					}
				} 
			}
			var pt:FlxSprite = null;
			for (i in 0...particles.length) {
				pt = particles.members[i];
				
				if (pt.exists && pt.velocity.y > 0) {
					if (parent_state.tm_bg.getTileCollisionFlags(pt.x + pt.width / 2, pt.y) != 0) {
						pt.exists = false;
					}
				}
			}
			
			if (biggest_boost != 0) {
				if (boost_ticks > 0 && R.player.get_shield_dir() == 2) {
					boost_ticks = 2;
					R.player.do_vert_push(2.3 * biggest_boost);
				} else {
					if (R.player.get_shield_dir() == 2) {
						R.player.do_vert_push(biggest_boost*1.5);
					} else {
						R.player.do_vert_push(biggest_boost);
					}
				}
			}
			
			if (nr_exist == 0) {
				for (i in 0...particles.length) {
					pt = particles.members[i];
					if (pt != null && pt.exists) {
						pt.animation.play("idle_end");
					}
				}
				this.mode = this.MODE_IDLE;
				this.animation.play("idle");
			}
		}
		
		super.update(elapsed);
	}
}