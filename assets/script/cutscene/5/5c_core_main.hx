
var chunksize = 300;
if (!this.child_init) {
	this.child_init = true;
	this.only_visible_in_editor = true;
	this.has_trigger = true;
	this.make_trigger(this.x, this.y, 160, 32);
	
	this.make_child("radio_depth_cpu",false); // main computer
	this.make_child("radio_depth_cpu_bar", false, "cpu"); // energy bar
	
	this.make_child("radio_depth_light",false,"idle"); // light 1
	this.make_child("radio_depth_light", false, "idle"); // lgiht 2
	
	this.make_child("radio_depth_monitor_bar",false,"heat"); // heating bar
	
	this.sprites.members[2].exists = false;
	this.sprites.members[3].exists = false;
	
	this.play_music("tower_core",false);
	
	this.s1 = -1; // initialize positions of sprites
	this.s3 = 0;
	this.s2 = 0;
	
	
	
	//this._trace("DEBUG 5c_core_main");
	//this.set_ss("i2", "core1", 1, 1);
	//this.set_ss("i2", "core_enter", 1, 1);
	//this.set_ss("i2", "core2", 1, 1);
	//this.set_ss("i2", "core3", 1, 1);
	
	var sum = 0;
	if (1 == this.get_ss("i2", "core1", 1)) sum++;
	if (1 == this.get_ss("i2", "core2", 1)) sum++;
	if (1 == this.get_ss("i2", "core3", 1)) sum++;
	
	
	if (sum == 1) {
		this.s2 = chunksize;
	} else if (sum == 2) {
		this.s2 = chunksize*2;
	} else if (sum == 3) {
		this.s2 = chunksize*3;
	}
	
	if (1 == this.get_ss("i2", "core_enter", 1)) {
		this.s3 = 1;
	}
	
	
}

// Assign sprites
var cpu = this.sprites.members[0];
var bar = this.sprites.members[1];
var l1 = this.sprites.members[2];
var l2 = this.sprites.members[3];
var heat = this.sprites.members[4];


// 60/second, 3600/minute
// do it in.. 15 sec increments? 900
this.s2 ++;
bar.scale.x =  (this.s2 / (chunksize * 4.0));
var maxt = 120;
var alarmt =90;
heat.scale.x = (this.t_1 / (60.0 * maxt)); // Bar goes to 80 px, over maxt seconds

if (R.TEST_STATE.fg1_parallax_layers.members.length > 1) {
	R.TEST_STATE.fg1_parallax_layers.members[1].alpha = 0.5 + .5 * heat.scale.x;
}

if (this.s3 == 1) {
	if (this.doff()) {
		this.t_1++;
	}
	if (this.t_1 == 60 * alarmt && !R.player.is_in_cutscene()) {
		l1.animation.play("on");
		l2.animation.play("on");
		this.dialogue("i2", "core_end", 7);
	} else if (this.t_1 > 60 * alarmt) {
		this.t_2 ++;
		if (this.t_2 == 40) {
			this.play_sound("depths_alarm.wav");
			this.t_2 = 0;
		}
	}
	if (this.t_1 >= 60 * maxt) {
		this.t_1 = 60 * maxt;
		if (R.access_opts[3] || R.access_opts[2] || R.story_mode) {
			// Don't die if playing with float mode or no damage
		} else if (R.player.is_in_cutscene() == false && this.doff()) {
			R.player.energy_bar.add_dark(10);
		}
	}
}


var sum = 0;
if (1 == this.get_ss("i2", "core1", 1)) sum++;
if (1 == this.get_ss("i2", "core2", 1)) sum++;
if (1 == this.get_ss("i2", "core3", 1)) sum++;

if (sum == 1) {
	if (this.s2 > chunksize*2) {
		this.s2 = chunksize*2;
	}
} else if (sum == 2) {
	if (this.s2 > chunksize*3) {
		this.s2 = chunksize*3;
	}
} else if (sum == 3) {
	if (this.s2 > chunksize*4) {
		this.s2 = chunksize * 4;
		// All consoles done and full, so go to end
		if (this.s3 == 1 && this.doff()) {
			if (R.player.energy_bar.is_stable() && !R.player.is_dying()) {
				this.s3 = 2;
				this.s1 = 0;
				this.set_ss("i2", "core_enter", 2, 1);
			}
		}
	}
} else {
	if (this.s2 > chunksize) {
		this.s2 = chunksize;
	}
}


if (this.s1 == -1) {
	bar.origin.x = 0;
	bar.origin.y = 0;
	heat.origin.x = 0;
	heat.origin.y = 0;
	this.set_vars(cpu, this.x -16, this.y - cpu.height + 32, 1);
	this.set_vars(bar, cpu.x + 32, cpu.y + 16, 1);
	this.set_vars(heat, cpu.x+32, cpu.y +16, 1);
	
	this.s1 = 0;
	
}




/* enter, until initial cutscene is done */
if (this.s3 == 0) {
	if (this.s1 == 0) {
		if (R.player.overlaps(this.trigger)) {
			//this.checkpoint_on(33*16,22*16-R.player.height+1, "RADIO_DB");
			this.s1 = 1;
		}
		
	} else if (this.s1 == 1) {
		if (this.player_freeze_help()) {
			this.s1 = 2;
			R.player.enter_cutscene();
			R.player.pause_toggle(false); 
			R.player.animation.play("wll");
			R.player.facing = 0x1;
			R.player.velocity.x = -80;
		}
	} else if (this.s1 == 2) {
			R.player.velocity.x = -80;
		if (R.player.x < cpu.x + cpu.width) {
			R.player.animation.play("iln");
			R.player.velocity.x = 0;
			this.dialogue("i2", "core_enter", 0,false);
			this.s1 = 3;
		}
	} else if (this.s1 == 3 && this.doff()) {
		R.player.animation.play("wll");
		R.player.velocity.x = -80;		
		//R.player.drag.x = 0;
		R.player.pause_toggle(false); 
		this.s1 = 4;
	} else if (this.s1 == 4 && R.player.x < cpu.x - 6*16) {
		R.player.animation.play("iln");
		R.player.velocity.x = 0;
		this.dialogue("i2", "core_enter", 2);
		this.s1 = 5;
	} else if (this.s1 == 5) {
		if (this.doff()) {
			this.s3 = 1;
			this.s1 = 0;
			this.set_ss("i2", "core_enter", 1, 1);
			R.player.enter_main_state();
		}
	}
}
	
if (this.s3 == 2) {
	if (this.s1 == 0) {
		this.s1 = 2;
		this.play_sound("Elevator.wav");
		// Sound?  make sure ot have caption
		this.play_music("null", false);
		// signal children to shut up / reduce bars
		this.broadcast_to_children("stop");
		//this.dialogue("i2", "core_end", 0);
	} else if (this.s1 == 2) {
		if (R.player.is_on_the_ground(true) && this.player_freeze_help()) {
			this.s1 = 0;
			this.s3 = 3;
			R.player.energy_bar.dont_move_cutscene_bars = true;
			R.player.velocity.x = 0;
			
			if (R.gauntlet_mode) {
				this.dialogue("i2", "core_end", 0);
			} else {
				this.dialogue("i2", "core_end", 0, true, false);
			}
		}
	}
} else if (this.s3 == 3) {
	if (this.s1 == 0 && this.doff()) {
		
		if (R.gauntlet_mode) {
			this.change_map("GM_1", 86, 13, true);
			this.set_event(48);
			this.s1 = 3;
			return;
		}
		
		//public static inline var radio_depths_done:Int = 48;
		//this.checkpoint_off();
		R.player.energy_bar.OFF = true;
		R.player.energy_bar.dont_move_cutscene_bars = true;
		R.player.enter_cutscene();
			//R.player.animation.play("irn");
			//R.player.facing = 0x10;
		R.player.energy_bar.dont_move_cutscene_bars = true;
		R.easycutscene.start("3b_golem");
		R.player.energy_bar.exit_extremes();
		R.TEST_STATE.dialogue_box.speaker_always_none = true;
		R.player.energy_bar.visible = false;
		this.s1 = 1;
	} else if (this.s1 == 1) {
		if (R.easycutscene.ping_last) {
			this.set_ss("i2", "crowd_hastings", 1, 1);
			this.set_ss("i2", "mayor_sad", 1, 1);
			R.player.energy_bar.dont_move_cutscene_bars = false;
			R.player.energy_bar.visible = true;
			this.s1 = 2;
		}
	} else if (this.s1 == 2) {
		this.set_event(48);
		this.change_map("WF_HI_1", 35, 22, true);
		this.s1 = 3;
	}
}