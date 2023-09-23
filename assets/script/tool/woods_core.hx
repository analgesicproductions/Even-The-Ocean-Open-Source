if (this.state_1 == 1) {
	if (this.context_values[0] == 0 && R.event_state[7] == 1) { // Woods core left
		this.state_1 = 2;
		this.animation.play("on");
	} else if (this.context_values[0] == 1 && R.event_state[8] == 1) { // Woods core right
		this.state_1 = 2;
		this.animation.play("on");
	} else if (this.nr_ENERGIZE_received > 0) {
		if (this.context_values[0] == 0) {
			R.set_flag(7,true);
		} else if (this.context_values[0] == 1) {
			R.set_flag(8, true);
		}
	}
} else if (this.state_1 == 0) {
	this.animation.play("off");
	this.state_1 = 1;
}
