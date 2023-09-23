//{ trainsprite
if (!this.child_init) {
	this.child_init = true;
	this.width = this.height = 16;
	this.animation.play("train");
	if (this.get_ss("ending", "city_enter", 1) == 1) {
		this.animation.play("sunset");
	}
}