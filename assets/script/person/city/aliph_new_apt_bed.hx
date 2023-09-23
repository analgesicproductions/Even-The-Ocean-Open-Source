//{ aliph_new_apt_bed
if (!this.child_init) {
	this.child_init = true;
	this.s1 = 0;
	this.s2 = 0;
	this.only_visible_in_editor = true;
	
	//this._trace("DEBUG aliph_new_apt_bed after g2_1 fight");
	//this.set_ss("g2_1", "yara", 1, 2);
	
	//this._trace("DEBUG aliph_new_apt_bed after g2_2");
	//this.set_event(38);
	//this.set_ss("g2_2", "debrief", 1, 1);
	
	
	
	// Post-g2_2 debriefing
	if (this.get_ss("g2_2", "debrief", 1) == 1 && this.get_ss("g2_2", "bed", 1) == 0) {
		this.s3 = 10;
		this.play_music("wf_lo_res");
	} else if (this.get_ss("g2_1", "aliph_apt", 1) == 0 && this.get_ss("g2_1", "yara", 1) > 0) {
		this.s3 = 5;
		this.play_music("wf_lo_res");
	} else {
		this.s3 = 0;
	}
	this.make_child("aliph_new_apt_bed_sprite", false, "idle");
	this.set_vars(this.sprites.members[0], this.x, this.y, 1);
}
var bed = this.sprites.members[0];


// "I don't need to use this right now"
if (this.s3 == 0) {
	if (this.s1 == 0) {
		if (this.try_to_talk(0, bed)) {
			this.s1 = 1;
			this.dialogue("g2_1", "aliph_new_bed", 0);
		}
	} else if (this.s1 == 1) {
		if (this.doff()) {
			this.s1 = 0;
		}
	}
}

// After yara G2_1 fight.
if (this.s3 == 5) {

if (this.s1 == 0) {
	if (this.try_to_talk(0, bed)) {
		this.s1 = 1;
		this.dialogue("g2_1", "aliph_new_bed", 1);
	}
} else if (this.s1 == 1) {
	if (this.d_last_yn() == 1) {
		this.s1 = 2;
	R.player.energy_bar.set_energy(128);
	} else if (this.doff()) {
		this.s1 = 0;
	}
} else if (this.s1 == 2) {
	if (this.doff()) {
		this.s1 = 3;
		this.set_ss("g2_1", "aliph_apt", 1, 1);
	}
} else if (this.s1 == 3) {
	if (this.doff()) {
		this.change_map(this.get_map("aliph_new_apt"), 1, 1, true);
		this.s1 = 4;
	}
}
}

if (this.s3 == 10) {

if (this.s1 == 0) {
	if (this.try_to_talk(0, bed)) {
		this.s1 = 1;
		this.dialogue("g2_2","bed", 0);
	}
} else if (this.s1 == 1) {
	if (this.d_last_yn() == 1) {
		this.s1 = 2;
		
	R.player.energy_bar.set_energy(128);
	} else if (this.doff()) {
		this.s1 = 0;
	}
} else if (this.s1 == 2) {
	if (this.doff()) {
		this.s1 = 3;
		this.set_ss("g2_2","bed", 1, 1);
	}
} else if (this.s1 == 3) {
	if (this.doff()) {
		R.player.enter_cutscene();
		this.change_map(this.get_map("aliph_new_apt"), 1, 1, false);
		this.s1 = 4;
	}
}	
}
