//{ yara_worldmap
if (!this.child_init) {
	this.child_init = true;
	this.s1 = 0;
	
	
	//this._trace("debug yaraending worlmdap");
	//this.set_ss("s3", "last_debrief", 1, 1);
	//this.set_ss("ending", "outside_wf", 1, 0);
	//this.set_ss("ending", "city_enter", 1, 0);
	 
	// in set 3
	if (this.get_ss("s3", "last_debrief", 1) != 0) {
		if (this.get_ss("ending","outside_wf",1) == 1) {
			this.SCRIPT_OFF = true;
			this.alpha = 0;
			return;
		} else {
			this.s2 = 2;
		}
	} else {
		this.SCRIPT_OFF = true;
		this.alpha = 0;
		return;
	}
	
	
	this.width += 24;
	this.height += 24;
	this.offset.set(-12,-12);	
	this.s3 = 0;
	this.has_trigger = true;
	this.make_trigger(this.x - 60, this.y - 60, 120, 110);
}


	if (this.s1 == 0) {
		if (R.activePlayer.overlaps(this.trigger)) {
			R.worldmapplayer.facing = 0x0100;
			R.worldmapplayer.animation.play("idle_u");
			R.worldmapplayer.pause_toggle(true);
			this.dialogue("ending", "outside_wf", 0);
			this.set_ss("ending", "outside_wf", 1, 1);
			this.s1 = 1;
		}
	} else if (this.s1 == 1) {
		if (this.doff()) {
			R.worldmapplayer.facing = 0x0100;
			this.s1 = 2;
			R.worldmapplayer.pause_toggle(false);
			this.change_map("WF_LO_0", 1, 1, true);
		}
	}