//{ radio_depth_sub
//script s "cutscene/5/5c_core_sub.hx"
//}
if (!this.child_init) {
	this.child_init = true;
	this.only_visible_in_editor = true;
	this.make_child("radio_depth_monitor",false,"off"); // monitor
	this.make_child("radio_depth_monitor_bar",false); // energy bar
	this.make_child("radio_depth_light",false,"idle"); // light 1
	this.make_child("radio_depth_light", false, "idle"); // lgiht 2
	this.s1 = -1; // initialize positions of sprites
}

var cpu = this.sprites.members[0];
var bar = this.sprites.members[1];
var l1 = this.sprites.members[2];
var l2 = this.sprites.members[3];

if (this.s1 == -1) {
	
	bar.origin.x = 0;
	bar.origin.y = 0;
	
	this.set_vars(cpu, this.x +16, this.y - cpu.height + 32, 1);
	this.set_vars(l1,cpu.x - 32,cpu.y -16, 0);
	this.set_vars(l2, cpu.x +cpu.width + 16, cpu.y - 16, 0);
	this.set_vars(bar, cpu.x + 8, cpu.y + 16, 0);
	
	this.s1 = 0;
	
	if (this.context_values[0] == 0) {
		if (1 == this.get_ss("i2", "core1", 1)) {
			cpu.animation.play("on");
		}
		this.s2 = 0;
	} else if (this.context_values[0] == 1) {
		if (1 == this.get_ss("i2", "core2", 1)) {
			cpu.animation.play("on");
		}
		this.s2 = 1;
	} else if (this.context_values[0] == 2) {
		if (1 == this.get_ss("i2", "core3", 1)) {
			cpu.animation.play("on");
		}
		this.s2 = 2;
	}
}

if (this.s1 == 0 && this.doff()) {
	if (1 == this.get_ss("i2", "core1", 2)) {
		return;
	}
	if (this.try_to_talk(0, cpu)) {
		if (this.s2 == 0 && 1 == this.get_ss("i2", "core1", 1)) {
			this.dialogue("i2", "core_end", 5);
		} else if (this.s2 == 1 && 1 == this.get_ss("i2", "core2", 1)) {
			this.dialogue("i2", "core_end", 5);
		} else if (this.s2 == 2 && 1 == this.get_ss("i2", "core3", 1)) {
			this.dialogue("i2", "core_end", 5);
		} else {
			R.player.enter_cutscene();
			if (this.s2 == 0) {
				this.do_laser_game(0, "RADIO_DB_1");
			} else if (this.s2 == 1) {
				this.do_laser_game(0, "RADIO_DB_2");
			} else if (this.s2 == 2) {
				this.do_laser_game(0, "RADIO_DB_3");
			}
			this.s1 = 1;
		}
	}
} else if (this.s1 == 1) {
	if (this.do_laser_game(1)) {
		this.do_laser_game(2);
		this.s1 = 0;
		
		R.player.enter_main_state();
		
		if (this.s2 == 0) {
			this.set_ss("i2", "core1", 1, 1);
		} else if (this.s2 == 1) {
			this.set_ss("i2", "core2", 1, 1);
		} else if (this.s2 == 2) {
			this.set_ss("i2", "core3", 1, 1);
		}
		
			cpu.animation.play("on");
		var sum = 0;
		if (1 == this.get_ss("i2", "core1", 1)) sum++;
		if (1 == this.get_ss("i2", "core2", 1)) sum++;
		if (1 == this.get_ss("i2", "core3", 1)) sum++;
		
		if (sum == 1) {
			this.dialogue("i2", "core_end", 3);
		} else if (sum == 2) {
			this.dialogue("i2", "core_end", 4);
		} else {
			this.dialogue("i2", "core_end", 6);
		}
		
	}
} 

//l1.animation.play("on");
			//l2.animation.play("on");
			//this.play_sound("depths_alarm.wav");
			//l1.animation.play("idle");
			//l2.animation.play("idle");

//bar.scale.x = this.s2;
 
		//this.broadcast_to_children("energize_tick_l");
