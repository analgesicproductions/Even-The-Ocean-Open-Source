	//{ hill_lock
if (this.s1 == 0) {
	// set in storeroom_trigger before the transition to the inner VBT cutscene
	//this.set_ss("hill", "storeroom_outside", 1, 1);
	if (this.get_scene_state("hill", "storeroom_inside", 1) == 0) {
		this.s1 = 1;
	} else {
		this.animation.play("open");
		this.s1 = 2;
		//this.y = this.iy - this.height;
	}
	this.immovable = true;
} else if (this.s1 == 1) {
	this.player_separate(this);
	if (this.nr_LIGHT_received > 0) {
		//this.velocity.y = -20;
		//if (this.y < this.iy - this.height) {
			//this.y = this.iy - this.height;
			this.s1 = 2;
		//}
	}
}