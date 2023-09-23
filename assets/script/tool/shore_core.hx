if (this.state_1 == 1) {
	if (this.nr_ENERGIZE_received > 0) {
		this.state_1 = 2;
		this.animation.play("on");
		if (this.context_values[0] == 1) {
			R.set_flag(9, true);
		}
	}
} else if (this.state_1 == 0) {
	if (R.event_state[9] == 1&& this.context_values[0] == 1) {
		this.state_1 = 2;
		this.animation.play("on");
	} else {
		this.animation.play("off");
		this.state_1 = 1;
	}
}
