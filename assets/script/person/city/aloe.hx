//{ aloe
if (!this.child_init) {
	this.child_init = true;
	this.s1 = 0;
	
	//this._trace("dave debug");
	//this.set_event(37);
	if (this.event(39)) {
		this.only_visible_in_editor = true;
		this.SCRIPT_OFF = true;
		return;
	}
}

// doesnt do complicated stuff atm, maybe ever
if (this.s1 == 0) {
	if (this.try_to_talk()) {
		if (this.get_ss("city", "aloe", 1) == 0) {
			this.set_ss("city", "aloe", 1, 1);
			this.dialogue("city", "aloe", 0);
			this.s1 = 1;
		} else {
			if (this.get_ss("city", "aloe", 2) == 0 && 1 == this.get_ss("city", "wf_j", 1)) {
				this.set_ss("city", "aloe", 2, 1);
				this.dialogue("city", "aloe", 1);
				this.s1 = 1;
			} else {
				this.dialogue("city", "aloe", 4);
				//todo
				this.s1 = 1;
			}
		}
	}
} else {
	if (this.doff()) {
		this.s1 = 0;
	}
}