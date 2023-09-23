if (!this.child_init) {
	this.child_init = true;
}

	
if (this.s1 == 0) {
	if (this.try_to_talk()) {
		this.s1 = 1;
		this.dialogue("river", "guard_1", 0);
	}
} else {
	if (this.doff()) {
		this.s1 = 0;
	}
}
