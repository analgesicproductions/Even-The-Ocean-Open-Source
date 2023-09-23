
if (!this.child_init) { 
	this.child_init = true;
	this.make_child("memory_bay",false,"mem"); // bay 
	this.make_child("memory_trent",false,"mem"); // trent
}	

var bay = this.sprites.members[0];
var trent = this.sprites.members[1];
trent.scale.x = -1;


if (this.s1 == 0) {
	
	// Only show up after getting hte map from vera
	if (this.get_scene_state("hill", "room_vera_after_bay", 1) == 0) {
		this.s1 = 3;
		this.visible = false;
		return;
	}
	// Only one of these shows up
	if (this.context_values[0] ==0) { // Location B1
		if (this.get_scene_state("hill", "soup_memory", 1) == 2) {
			this.visible = false;
		}
	} else { // Location B2
		if (this.get_scene_state("hill", "soup_memory", 1) == 1) {
			this.visible = false;
		}
	}
	if (this.visible) {
		if (this.s2 == 0) {
			
				this.t_1++;
				if (this.t_1 >= 120) {
					this.t_1 = 0;
				}
				this.alpha = 0.8 + 0.2 * this.get_sin(this.t_1 * 3);
			
			if (this.try_to_talk()) {
				if (this.get_ss("hill", "soup_memory", 1) > 0) {
					this.dialogue("hill", "soup_memory", 1);
					this.s2 = 2;
				} else {
					this.dialogue("hill", "soup_memory", 2);
					this.s2 = 1;
				}
			} 
			
		} else if (this.s2 == 1 && this.doff()) {
			R.player.enter_cutscene();
			this.t_1 = 30;
			if (this.fade_out(this) && 	this.fade_out(R.player)) {
				this.s1 = 1;
				this.s2 = 0;
				this.set_vars(bay, this.x + 32, this.y, 0, true);
				this.set_vars(trent, this.x - 16, this.y, 0, true);
			}
		} else if (this.s2 == 2) {
			if (this.d_last_yn() == 1) {
				this.s2 = 1;
			} else if (this.d_last_yn() == 0) {
				this.s2 = 0;
			}
		}
	}
} else if (this.s1 == 1) {
	if (this.fade_in([bay,trent])) {
		this.s1 = 2;
	}
} else if (this.s1 == 2) {
	if (this.s2 == 0) {
		this.dialogue("hill", "soup_memory", 3);
		this.s2 = 1;
	} else if (this.s2 == 1) {
		if (this.dialogue_is_on() == false) {
			this.s2 = 2;
		}
	} else if (this.s2 == 2) {
		if (this.fade_out([trent, bay]) && this.fade_in(this) && this.fade_in(R.player)) {
			this.s2 = 0;
			this.s1 = 0;
			//R.player.pause_toggle(false);
			
			R.player.enter_main_state();
			
			if (this.context_values[0] ==0) { // Location B1
				this.set_scene_state("hill", "soup_memory", 1, 1);
			} else { // Location B2
				this.set_scene_state("hill", "soup_memory", 1, 2);
			}
		}
	}
} else if (this.s1 == 3) {
	if (this.get_scene_state("hill", "room_vera_after_bay", 1) == 1) {
		this.s1 = 0;
		this.visible = true;
	}
}
	