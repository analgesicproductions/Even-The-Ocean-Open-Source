// nibble
//idle
// pace back and forth
// within a certain range
// ocacsionally stop to eat grass.
this.t_1 ++; 
if (this.state_1 == 0) {
	if (this.t_1 > 60) {
		this.animation.play("nibble");
		this.velocity.x = 0;
		this.state_1 = 2;
		this.t_1 = 0;
	}
} else if (this.state_1 == 1) {
	if (this.t_1 > 60) {
		this.animation.play("nibble");
		this.velocity.x = 0;
		this.state_1 = 3;
		this.t_1 = 0;
	}
} else if (this.state_1 == 2) {
	if (this.t_1 > 60) {
		this.animation.play("idle");
		this.velocity.x = 100;
		this.t_1 = 0;
		this.state_1 = 1;
	}
} else if (this.state_1 == 3) {
	if (this.t_1 > 60) {
		this.animation.play("idle");
		this.velocity.x = -100;
		this.t_1 = 0;
		this.state_1 = 0;
	}
}