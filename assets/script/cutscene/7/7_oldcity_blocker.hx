// blocks leaving the old city
if (!this.child_init) {
	this.child_init = true;
	this.only_visible_in_editor = true;
	

	//R.inventory.set_item_found(0, 19, true);
	//R.inventory.is_item_found(19) && 

	//this._trace("DEBUG: 7_oldcitybllocker postg3_3 debrief");	
	//this.set_event(45);
	//this.set_ss("s3", "last_debrief", 1, 1);
	//this.set_ss("s3", "first_sleep", 1, 1);
	
	
	//this._trace("7_oldcityblocker");	
	//this.set_event(44);
	//this.set_ss("s3", "kv_gotmaps_wf", 1, 1);
	
	if (this.event(50)) {
		this._trace("oldcity blocker off bc ending done");
		this.SCRIPT_OFF = true;
		return;
	}
	
	
	// tower view
	if (R.TEST_STATE.MAP_NAME == "KV_1" && this.context_values[0] == 1) {
		if (1 == this.get_ss("s3", "tower_view", 1)) {
			
			this.SCRIPT_OFF = true;
			return;
		}
		
		this.only_visible_in_editor = true;
	this.has_trigger = true;
	this.make_trigger(this.x , this.y, 16, 200);
	return;
	}
	
	// in KV RADIO 
	 
	// Block if haven't told WF you got the maps
	if (this.get_ss("s3", "kv_gotmaps_wf", 1) == 0) {
		if (this.get_ss("s3", "tower_view", 1) == 0) {
			this.s1 = 100;
		} else {
			this.s1 = 0;
		}
	// Block after golem 1 and 2 if you didnt go to seep yet
	} else if (this.event(43) && this.get_ss("s3", "yara", 1) == 0) {
		this.s1 = 0;
		this.s2 = 1;
	} else if (this.event(44) && this.get_ss("s3", "yara_2", 1) == 0) {
		this.s1 = 0;
		this.s2 = 1;
	} else {
		this.SCRIPT_OFF = true;
		this.only_visible_in_editor = true;
		return;
	}
	this.has_trigger = true;
	this.make_trigger(this.x , this.y, 16, 200);
}
//this._trace(R.player.y);
//this._trace(R.player.last.y);

if (this.s1 == 100) {
	if (this.get_ss("s3", "tower_view", 1) == 1) {
		this.s1 = 0;
	}
}


// run back to the left
if (this.s1 == 0) {
	if (this.trigger.overlaps(R.player)) {
		this.s1 = 1;
	}
} else if (this.s1 == 1) {
	if (this.player_freeze_help()) {
		if (R.TEST_STATE.MAP_NAME == "KV_1" && this.context_values[0] == 1) {
			this.set_ss("s3", "tower_view", 1, 1);
			R.player.enter_cutscene();
			this.s1 = 2;
			R.easycutscene.activate("3f_kv_radio");
		} else {
			R.player.pause_toggle(false);
			R.player.enter_cutscene();
			R.player.velocity.x = 80;
			R.player.animation.play("wrr");
			this.s1 = 11;
		}
	}
} else if (this.s1 == 2) {
	if (R.easycutscene.is_off()) {
		this.s1 = 3;
		R.player.enter_main_state();
	}
} else if (this.s1 == 11) {
	
	if (R.player.x > this.trigger.x + this.trigger.width + 16) {
		R.player.velocity.x = 0;
		R.player.animation.play("irn");
		R.player.facing = 0x0010;
		if (this.s2 == 0) {
			this.dialogue("s3", "karavold_misc", 0);
		} else if (this.s2 == 1) {
			this.dialogue("s3", "karavold_misc", 1);
		}
		this.s1 = 12;
	}
} else if (this.s1 == 12) {
	if (this.doff()) {
		this.s1 = 0;
		R.player.enter_main_state();
	}
}
