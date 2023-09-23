//{ river_locked_gate
if (!this.child_init) {
	this.child_init = true;
	this.s1 = 0;
	this.s2 = 0;
	this.immovable = true;
	if (this.get_ss("river", "jr_2", 1) == 1) {
		this.s1 = 2;
		this.alpha = 0;
		//this.y = this.iy - this.height;
	}
	this.width = 16;
	this.height = 48;
	this.offset.set(16, 16);
}

if (this.s1 == 0) {
	
this.player_separate(this);
	if (this.nr_LIGHT_received > 0) {
		this.s1 = 3;
	}
	if (this.try_to_talk(2, this, true)) {
		this.s1 = 1;
		this.dialogue("river", "locked_gate", 0);
	}
} else if (this.s1 == 1) {
	
this.player_separate(this);
	if (this.doff()) this.s1 = 0;
}

if (this.s1 == 3) {
	//this.velocity.y = -40;
	this.alpha = this.alpha - 0.03;
	//if (this.y <= this.iy - this.height) {
		//this.y = this.iy - this.height;
	if (this.alpha <= 0) {
		this.alpha = 0;
		this.velocity.y = 0;
	}
}