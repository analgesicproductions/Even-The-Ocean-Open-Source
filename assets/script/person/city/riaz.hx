//{ riaz
if (!this.child_init) {
	this.child_init = true;
	this.s1 = 0;
	
	if (this.get_event(39) && !this.get_event(48)) {
		this.animation.play("stand");
		this.y += 4;
	}
}

if (this.s1 == 0) {
	if (this.try_to_talk()) {
		if (this.event(39)) {
			// ?
			this.dialogue("city", "riaz", 6);
		} else if (this.event(38)) {
			this.dialogue("city", "riaz", 5);
		} else if (this.event(37)) {
			this.dialogue("city", "riaz", 4);
		} else if (this.event(31)) {
			this.dialogue("city", "riaz", 3);
		} else if (this.event(30)) {
			this.dialogue("city", "riaz", 2);
		} else if (this.event(29)) {
			this.dialogue("city", "riaz", 1);
		} else {
			this.dialogue("city", "riaz", 0);
		}
		this.s1 = 1;
	}
} else {
	if (this.doff()) {
		this.s1 = 0;
	}
}