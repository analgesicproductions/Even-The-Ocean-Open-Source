if (this.mode == this.mode_moving) {
	
	if (this.velocity.x < 0) {
		if (0 != this.parent_state.tm_bg.getTileCollisionFlags(this.x, this.y + this.width / 2)) {
			this.velocity.x = 150;
		}
	} else {
		if (0 != this.parent_state.tm_bg.getTileCollisionFlags(this.x + this.width, this.y + this.width / 2)) {
			this.velocity.x = -150;
		}
	}
} else {
	this.mode = this.mode_moving;
	this.velocity.x = 50;
	
}

//this.alpha = this.health / 100.0;
