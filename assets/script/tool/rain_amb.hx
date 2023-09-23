if (this.dec_and_check_if_timer_done(0)) {
	
	if (this.state_1 == 0) {
		this.play_s("rainsfx.ogg");
		this.state_1 = 1;
	} else {
		this.play_s("rainsfx.ogg");
		this.state_1 = 0;
	}
	this.set_rand_timer(0, 10.6,10.6);
}