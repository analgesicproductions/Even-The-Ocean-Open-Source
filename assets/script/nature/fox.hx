// pounce_l
// pounce_r
// walk
// idle

// cv[0] = left point (absolute value)
// cv[1] = right point
// cv[2] = max delta from a point

// set two random points near  context_values[0] and 1 within #2
// walk between them or jump?


if (this.state_1 == 0) { // timers
	this.DOES_COLLIDE = true;
	this.acceleration.y  = 200;
	this.tm_1 = 30 + this.rand_int(0, 30);
	this.state_1 = 1;
	this.animation.play("idle");
} else if (this.state_1 == 1) { // wait to move mode
	this.t_1 ++;
	if (this.t_1 > this.tm_1) {
		this.t_1 = 0;
		if (this.random() > 0.5) {
			this.animation.play("walk_l");
			this.state_1 = 2; // walk to left point
			this.velocity.x = -40 + this.random() * -10;
		} else {
			this.animation.play("walk_r");
			this.state_1 = 3; // walk to right point
			this.velocity.x = 40 + this.random() * 10;
		}
	}
} else if (this.state_1 == 2) { // walking left
	if (this.x < (this.ix - this.context_values[0])) {
		this.velocity.x = 0;
		this.animation.play("idle");
		
		if (this.random() > 0.5) { // pounce right
			this.animation.play("pounce_r");
			this.velocity.x = 60;
			this.velocity.y = -90;
			this.state_1 = 4;
		} else {
			this.animation.play("walk_r");
			this.state_1 = 3; // walk to right point
			this.velocity.x = 40 + this.random() * 10;
		}
	}
} else if (this.state_1 == 3) { // walking right
	if (this.x > (this.ix + this.context_values[1])) {
		this.velocity.x = 0;
		this.animation.play("idle");
		if (this.random() > 0.5) { // pounce left
			this.animation.play("pounce_l");
			this.velocity.x = -60;
			this.velocity.y = -90;
			this.state_1 = 5;
		} else {
			this.animation.play("walk_l");
			this.state_1 = 2; // walk to right point
			this.velocity.x = -40 - this.random() * 10;
		}
	}
} else if (this.state_1 == 4) { // pouncing from the left? 
	if (this.touching_down()) {
		this.velocity.y = 0;
		this.velocity.x = 0;
		this.state_1 = 0;
	}
} else if (this.state_1 == 5) { // pouncindg from right
	if (this.touching_down()) {
		this.velocity.y = 0;
		this.velocity.x = 0;
		this.state_1 = 0;
	}
} else if (this.state_1 == 6) {
	
} else if (this.state_1 == 7) {
	
}