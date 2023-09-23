if (this.dec_and_check_if_timer_done(0)) {
	
	r = Math.random();
	if (r < 0.25) {
		this.play_s("cave_breath_1.ogg");
	} else if (r < 0.5) {
		this.play_s("cave_breath_2.ogg");
	} else if (r < 0.75) {
		this.play_s("cave_breath_3.ogg");
	} else {
		this.play_s("cave_breath_4.ogg");
	}
	this.set_rand_timer(0, 2.5, 4);
} else {
	
}