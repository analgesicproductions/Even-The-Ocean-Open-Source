if (this.s1 == 0) {
	this.s1 = 1;
	
	this.has_trigger = true;
	this.make_trigger(this.x - 96, this.y, 32, 32);
}
if (this.s1 == 2) {

	// moving to sappad
	if (this.d_last_yn() == 3) {
		this.s2 = 2;
		this.s1 = 3;
		return;
	}
	if (this.doff()) {
		this.s1 = 1;
	} else {
	}
	return;
}


if (this.s2 == 2) {
	this.t_1 ++;
	if (this.s1 == 3) {
		this.velocity.x = -80;
		this.animation.play("walk_l");
		this.s1 = 4;
		this.t_1 = 0;
	} else if (this.s1 == 4 && this.t_1 > 30) {
		this.t_1 = 0;
		this.velocity.x = 0;
		this.animation.play("idle_l");
		this.dialogue("hill", "wilbert", 9);
		this.s1 = 5;
	} else if (this.s1 == 5 && this.doff()) {
		this.velocity.x = -80;
		this.animation.play("walk_l");
		this.s1 = 6;
		this.t_1 = 0;
	} else if (this.s1 == 6 && this.t_1 > 30) {
		this.s1  = 7;
		this.velocity.x = 0;
		this.animation.play("idle_l");
		this.play_sound("SapPad.wav");
		this.broadcast_to_children("energize_tick_l");
		this.broadcast_to_children("animate");
	} else if (this.s1 == 7 && this.t_1 > 60) {
		this.t_1 = 0;
		this.dialogue("hill", "wilbert", 10);
		this.s1 = 8;
		this.set_ss("hill", "wilbert", 1, 1);
		this.broadcast_to_children("energize");
	} else if (this.s1 == 8 && this.doff()) {
		this.s2 = 0;
		this.s1 = 1;
	}
} else {
	if (this.try_to_talk(0,this.trigger)) {
		this.dialogue("hill", "wilbert_init", 0);
		this.s1 = 2;
	}
}