if (!this.child_init) {
	this.alpha = 0;
	this.child_init = true;
	//this.only_visible_in_editor = true;
	if (0 == this.get_ss("i2", "yara", 1)) {
		this.SCRIPT_OFF = true;
		return;
	}
	// TODO CHANGE
	this.make_child("worldmap_tunnel", false);
	this.s1 = -1;
	return;
}

var tunnel = this.sprites.members[0];
//this._trace(tunnel.x);
	tunnel.ix = this.children[0].x+24;
	tunnel.iy = this.children[0].y+4;
	//tunnel.scale.x = -1;
if (this.s1 == -1) {
	this.s1 = 0;
	if (this.get_ss("s3", "map1_tunnel_vis", 1) == 1) {
		this.set_vars(tunnel, this.children[0].x + 16, this.children[0].y - 8, 0, true);
		tunnel.alpha = 1;
		this.s1 = 10;
		this.children[0].behavior_to_open();
	}
}
if (this.s1 == 0 ) {
	if (R.attempted_door == "TUNNEL_2") {
		R.attempted_door = "";
		if (this.get_ss("s3", "map1_tunnel_vis", 1) == 0) {
			this.play_sound("clam_1.wav");
			this.set_ss("s3", "map1_tunnel_vis", 1, 1);
			this.s1 = 3;
		this.children[0].behavior_to_open();
		}
	}
}
if (this.s1 == 3) {
	if (this.fade_in(tunnel)) {
		this.s1 = 10;
		this.set_vars(tunnel, this.children[0].x + 16, this.children[0].y - 8, 1, true);
		this.children[0].behavior_to_open();
	}
}