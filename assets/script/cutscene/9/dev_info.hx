
//{ dev_info

if (!this.child_init) {
	this.child_init = true;
	
	/* Initialize state variables */
	this.s1 = 0;
	this.s2 = 0;
	
	
		//this._trace(123);
	 //communicationr (fro ending)
	//R.inventory.set_item_found(0, 30);
	
	
	// final is: the wf_lo_0 doesnt show till postgame, but all others do.
	if (R.inventory.is_item_found(30) || R.TEST_STATE.MAP_NAME != "WF_LO_0") {
		if (this.context_values[0] > 2) {
			// note reader
			if (R.inventory.is_item_found(0, 44)) {
				
			} else {
				this.only_visible_in_editor = true;
				this.s1 = 0;
			}
		} 
		//this._trace(123);
	} else {
		this.only_visible_in_editor = true;
		this.s1 = -1;
	}
	
}


// Do stuff
if (this.s1 == 0) {
	if (this.context_values[0] == 1) {
		this.animation.play("joni");
	} else if (this.context_values[0] == 2) {
		this.animation.play("both");
	} else {
		this.animation.play("sean");
	}
	this.s1 = 1;
} else if (this.s1 == 1) {
	if (this.try_to_talk(0, this, true)) {
		if (this.context_values[0] == 1) {
			this.dialogue("p", "dj", this.context_values[1]);
		} else if (this.context_values[0] == 2) {
			this.dialogue("p", "db", this.context_values[1]);
		} else {
			this.dialogue("p", "ds", this.context_values[1]);
		}
		this.s1 = 2;
	}
} else if (this.s1 == 2 && this.doff()) {
	this.s1 = 1;
}
