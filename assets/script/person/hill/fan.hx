if (!this.child_init) {
	this.scale_first = false;
	this.scale.y = 0.5;
	this.width = 32;
	this.child_init = true;
}
if (this.s1 == 0) {
	if (this.get_scene_state("hill", "wilbert", 1) == 0) {
		this.s1 = 1;
	} else {
		this.s1 = 2;
		this.broadcast_to_children("energize");
		this.broadcast_to_children("superenergize");
		this.angularVelocity = 120;
	}
} else if (this.s1 == 1) {
	if (this.try_to_talk()) {
		this.dialogue("hill", "fan", 0);
	}
	
	this.t_1 ++;
	if (this.t_1 == 30) {
		this.t_1 = 0;
		// recv msg
		if (this.get_scene_state("hill", "wilbert", 1) == 1) {
			this.s1 = 2;
			this.angularVelocity = 120;
			this.broadcast_to_children("energize");
		}
	}
}