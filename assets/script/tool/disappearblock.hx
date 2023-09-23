

if (this.state_1 == 0) {
	this.state_1 = 1;
	this.tm_1 = 300;
} else if (this.state_1 == 1) {
	this.immovable = true;
	if (this.player_separate(this, R.player)) {
		this.t_1 ++;
	} else {
		this.t_1 = 0;
	}
	this.x = this.ix;
	this.y = this.iy;
	if (this.t_1 > this.tm_1) {
		this.state_1 = 2;
	}
} else if (this.state_1 == 2) {
	
}