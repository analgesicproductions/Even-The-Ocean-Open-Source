

// idle state, set a timer and direction and velocity when timers done
// walking state



if (this.state_1 == 0) {
		this.animation.play("idle");
	this.DOES_COLLIDE = true;
	this.acceleration.y = 50;
	this.tm_1 = this.rand_int(160, 360);
	this.state_1 = 1;
} else if (this.state_1 == 1) {
	this.t_1 ++;
	if (this.t_1 > this.tm_1) {
		this.t_1 = 0;
		this.state_1 = 2;
		this.tm_1 = this.rand_int(60, 180);
		if (this.random() > 0.75) {
			this.state_1 = 4;
			this.animation.play("play_dead");
		} else if (this.random() > 0.5) { // move right
			this.velocity.x = this.rand_int(20, 40);
			this.state_1 = 2;
			this.animation.play("move_r");
		} else {
			this.velocity.x = this.rand_int(-40, -20);
			this.state_1 = 3;
			this.animation.play("move_l");
		}
	}
} else if (this.state_1 == 2) { // walk _R
	if (this.is_near_floor_gap(true)) {
		this.state_1 = 3;
		this.velocity.x *= -1;
		this.animation.play("move_l");
	}
} else if (this.state_1 == 3) {
	if (this.is_near_floor_gap(false)) {
		this.state_1 = 2;
		this.velocity.x *= -1;
		this.animation.play("move_r");
	} 
} else if (this.state_1 == 4) { // play daed
	this.t_1 ++;
	if (this.t_1 > this.tm_1) {
		this.t_1 = 0;
		this.state_1 = 0;
	}
}

if (this.state_1 == 2 || this.state_1 == 3) {
	this.t_1 ++ ;
	if (this.t_1 > this.tm_1) {
		this.t_1 = 0;
		this.velocity.x = 0;
		this.state_1 = 0;
	}
}