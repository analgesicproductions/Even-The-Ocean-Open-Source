//{ dave
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

if (this.s1 == 0) {
	if (this.try_to_talk()) {
		if (this.event(39)) {
			this.dialogue("city", "dave2", 0);
		} else if (this.event(38)) {
			this.dialogue("city", "dave2", 0);
		} else if (this.event(37)) {
			this.dialogue("city", "dave2", 0);
		} else if (this.event(31)) {
			this.dialogue("city", "dave", 2);
		} else if (this.event(30)) {
			this.dialogue("city", "dave", 1);
		} else if (this.event(29)) {
			this.dialogue("city", "dave", 0);
		} else {
			// ??
			this.dialogue("city", "dave", 0);
		}
		this.s1 = 1;
	}
} else {
	if (this.doff()) {
		this.s1 = 0;
	}
}