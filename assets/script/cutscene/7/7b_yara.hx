//{ old_city_yara
// This is a BED sprite
// Sleep: After finding maps, after g3_1 and g3_2
if (!this.child_init) {
	this.child_init = true;
	this.s1 = 0;
	this.s2 = 0;
	if (R.gs1 == 1) { // Should be playing the Yara response scene
		this.visible = false;
		this.make_child("yara",false,"idle");
		this.make_child("humus", false, "idle");
		if (this.get_ss("s3", "yara_2", 1) == 1) {
			this.s1 = 11;
		} else if (this.get_ss("s3", "yara", 1) == 1) {
			this.s1 = 10;
		}
	} else { // Old city bed trigger
		//this._trace("DEBUG 7b_yara (oldcity post-g3_1 sleep)");
		//this.set_ss("s3", "debrief", 1, 1);
		
		//this._trace("DEBUG 7b_yara (oldcity post-g3_2 sleep)");
		//this.set_ss("s3", "yara", 1, 1);
		//this.set_ss("s3", "debrief_2", 1, 1);
		
		//this._trace("DEBUG 7b_yara (oldcity INITIAL (post-maps) sleep)");
		 
		if (this.get_ss("s3", "yara", 1) == 0 && this.get_ss("s3","debrief",1) == 1) {
			this.s1 = 0;
		} else if (this.get_ss("s3", "yara_2", 1) == 0 && this.get_ss("s3", "debrief_2", 1) == 1) {
			this.s1 = 1;
		} else if (R.inventory.is_item_found(19) && this.get_ss("s3", "first_sleep", 1) == 0) { // should be "if you got the maps"...can sleep, also set somethign to let u leave
			this.s1 = 3;
		} else {
			this.s1 = 2;
		}
	}
}
// Bed, after g3_1 time
if (this.s1 == 0) {
	if (this.s2 == 0) {
		if (this.try_to_talk(0,null,true)) {
			this.dialogue("s3", "bed", 0);
			this.s2 = 1;
		}
	} else if (this.s2 == 1) {
		if (this.doff()) {
			this.start_invisible_player_cutscene("WF_GOV_JAIL", 1, 1, true);
			this.s2 = 2;
			this.set_ss("s3", "yara", 1, 1);
			R.gs1 = 1;
		}
	}
	return;
// Bed, after g3_2 time 
} else if (this.s1 == 1) {
	
	if (this.s2 == 0) {
		if (this.try_to_talk(0,null,true)) {
			this.dialogue("s3", "bed", 0);
			this.s2 = 1;
		}
	} else if (this.s2 == 1) {
		if (this.doff()) {
			this.start_invisible_player_cutscene("WF_GOV_JAIL", 1, 1, true);
			this.s2 = 2;
			this.set_ss("s3", "yara_2", 1, 1);
			R.gs1 = 1;
		}
	}
	return;
// Bed, no event to triger
} else if (this.s1 == 2) {
	if (this.s2 == 0) {
		if (this.try_to_talk(0, null, true)) {
			this.s2 = 1;
			this.dialogue("s3", "bed", 1);
		}	
	} else if (this.s2 == 1) {
		if (this.doff()) {
			this.s2 = 0;
		}
	}
	return;
// After getting maps
} else if (this.s1 == 3) {
	if (this.s2 == 0) {
		if (this.try_to_talk(0,null,true)) {
			this.dialogue("s3", "first_sleep", 0,false);
			this.set_ss("s3", "first_sleep", 1, 1);
			this.s2 = 4;
			
		}
	} else if (this.s2 == 4 && this.doff()) {
		
			R.TEST_STATE.cutscene_handle_signal(0, [0.02], true); 
			this.s2 = 3;
	} else if (this.s2 == 3) {
		if (R.TEST_STATE.cutscene_just_finished(0)) {
			this.s2 = 1;
			this.t_1 = 0;
		}
	} else if (this.s2 == 1) {
		this.t_1 ++;
		if (this.t_1 > 90) {
		if (this.doff()) {
			R.player.energy_bar.set_energy(128);
			
			this.energy_bar_move_set(true, false);
			this.change_map(this.get_map("old_sleep"), R.player.x, R.player.y, false);
			this.s2 = 2;
		}
	}		 
	}
	return;
}

var yara = this.sprites.members[0];
var humus = this.sprites.members[1];

if (this.s1 == 10) {
	if (this.s2 == 0) {
		// this.cam_to_id(0); 
		
		R.player.energy_bar.set_energy(128);
		this.set_vars(yara, this.x + 64, this.y, 1);
		this.set_vars(humus, this.x, this.y, 1);
		this.s2 = 1;
	} else if (this.s2 == 1) {
		this.t_1 ++;
		if (this.t_1 > 60) {
			this.dialogue("s3", "yara", 0);
			this.s2 = 2;
		}
	} else if (this.s2 == 2 && this.doff()) {
		this.stop_invisible_player_cutscene(this.get_map("old_sleep"), 1, 1);
		this.s2 = 3;
		R.gs1 = 0;
	}
} else if (this.s1 == 11) {
	if (this.s2 == 0) {
		// this.cam_to_id(0); 
		R.player.energy_bar.set_energy(128);
		this.set_vars(yara, this.x + 64, this.y, 1);
		this.set_vars(humus, this.x, this.y, 1);
		this.s2 = 1;
	} else if (this.s2 == 1) {
		this.t_1 ++;
		if (this.t_1 > 60) {
			this.dialogue("s3", "yara_2", 0);
			this.s2 = 2;
		}
	} else if (this.s2 == 2 && this.doff()) {
		this.stop_invisible_player_cutscene(this.get_map("old_sleep"), 1, 1);
		this.s2 = 3;
		R.gs1 = 0;
	}
}
