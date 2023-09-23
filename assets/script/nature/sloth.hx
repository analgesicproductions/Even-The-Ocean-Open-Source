this.t_1 ++;
if (this.state_1 == 0 ) {
	if (this.t_1 > 300) {
		this.t_1 = 0;
		this.state_1 = 1;
		this.velocity.x = 3;
		this.animation.play("move");
	}
} else if (this.state_1 == 1) {
	if (this.t_1 > 100 ) {
		this.t_1 = 0;
		this.state_1 = 2;
		this.velocity.x = 0;
		this.animation.play("idle");
	}
}else if (this.state_1 == 2) { 
	if (this.t_1 > 300  ) {
		this.t_1 = 0;
		this.state_1 = 3;
		this.velocity.x = -3;
		this.animation.play("move");
	}
}else if (this.state_1 == 3) {
	if (this.t_1 > 100 ) {
		this.t_1 = 0;
		this.state_1 = 0;
		this.velocity.x = 0;
		this.animation.play("idle");
	}
}