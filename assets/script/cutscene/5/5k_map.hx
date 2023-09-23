//{ post_i2_map
if (!this.child_init) {
	this.child_init = true;
	this.only_visible_in_editor = true;
	this.s1 = 0;
	this.s2 = 0;
	this.has_trigger = true;
	this.make_trigger(this.x-100, this.y, 200, 32);
	//this._trace("DEBUG 5k_map");
	//this.set_ss("i2", "yara", 1, 1);
	if (this.get_ss("i2", "yara", 1) == 1 && 0 == this.get_ss("s3","post_i2_map",1)) {
	} else {
		this.SCRIPT_OFF = true;
		return;
	}
}
if (this.s1 == 0) {
	if (R.worldmapplayer.overlaps(this.trigger)) {
		this.dialogue("s3", "post_i2_map", 0);
		this.s1 = 1;
		this.set_ss("s3", "post_i2_map", 1, 1);
	}
}