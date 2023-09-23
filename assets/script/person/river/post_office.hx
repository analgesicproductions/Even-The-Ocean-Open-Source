//{ river_post_office
if (!this.child_init) {
	this.child_init = true;
	this.s1 = 0;
}
if (this.s1 == 0) {
	if (this.try_to_talk(0, this, false)) {
		this.s1 = 1;
		this.dialogue("river", "post_office", 0);
	}
} else if (this.s1 == 1 && this.doff()) {
	this.s1 = 0;
}