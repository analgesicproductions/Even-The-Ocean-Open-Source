if (this.state_1 == 0) {
	this.state_1 = 1;
	this.play_anim("idle_r");
} else if (this.state_1 == 1) {
	this.t_1 ++;
	if (this.t_1 > 10) {
		this.t_1 = 0;
		this.state_1 = 2;
	this.play_anim("idle_l");
	}
}  else if (this.state_1 == 2) {
	this.t_1 ++;
	if (this.t_1 > 10) {
		this.t_1 = 0;
		this.state_1 = 3;
		this.velocity.x = 50;
	this.play_anim("walk_r");
	}
	
}  else if (this.state_1 == 3) {
	this.t_1 ++;
	if (this.t_1 > 10) {
		this.t_1 = 0;
		this.state_1 = 4;
		this.velocity.x = -50;
	this.play_anim("walk_l");
	}
	
}  else if (this.state_1 == 4) {
	this.t_1 ++;
	if (this.t_1 > 10) {
		this.t_1 = 0;
		this.state_1 = 5;
		this.velocity.x = 0;
	this.play_anim("sit_r");
	}
	
}  else if (this.state_1 == 5) {
	this.t_1 ++;
	if (this.t_1 > 10) {
		this.t_1 = 0;
		this.state_1 = 6;
	this.play_anim("sit_l");
	}
}	 else if (this.state_1 == 6) {
	this.t_1 ++;
	if (this.t_1 > 10) {
		this.t_1 = 0;
		this.state_1 = 1;
		this.play_anim("idle_r");
	}
}