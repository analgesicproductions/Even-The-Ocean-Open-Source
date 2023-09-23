if (this.dec_and_check_if_timer_done(0)) {
	
	if (this.state_1 == 0) {
		this.play_s("stream_ambience_1.ogg");
		this.state_1 = 1;
	} else {
		this.play_s("stream_ambience_2.ogg");
		this.state_1 = 0;
	}
	this.set_rand_timer(0, 1.5,1.5);
}