if (this.state_1 == 0) {
	this.velocity.x = 100;
	if (this.midpoint_touching_right_on_tilemap()) {
		this.state_1 = 1;
	}
	
} else if (this.state_1 == 1) {
	this.velocity.x = -100;
	if (this.x < 0) {
		this.state_1 = 0;
	} else if (this.midpoint_touching_left_on_tilemap()) {
		this.state_1 = 0;
	}
}
	
if (this.velocity.x < 0) {
	this.velocity.x += (this.t_1 / 6);
} else {
	this.velocity.x -= (this.t_1 / 6);
}

this.y = this.iy + 16 * this.get_sin(this.t_1);

this.t_1++;

if (this.t_1 > 359) {
	this.t_1 = 0;
}


