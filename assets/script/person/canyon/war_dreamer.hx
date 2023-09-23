if (!this.child_init) {
	this.child_init = true;
	this.width -= 64;
	for( i in [0,1,2,3,4] ) {
		this.make_child("gunPoof");
	}
}
if (R.inventory.is_item_found(12) == true) {
	
	if (this.state_2 >= 1) {
		if (this.state_2 == 1 + this.sprites.length) {
			this.state_2 = 0;
		} else {
			this.t_2 ++;
			if (this.t_2 > 15) {
				this.t_2 = 0;
				this.shake(0.01, 0.1);
				this.play_sound("pew_hit.wav");
				this.sprites.members[this.state_2 - 1].exists = true;
				this.sprites.members[this.state_2 - 1].animation.play("l");
				this.sprites.members[this.state_2 - 1].move(this.x - 16 +128* this.random(), this.y - 32 + 128 * this.random());
				this.state_2++;
			}
		}
	}
	
	if (this.state_1 == 1) {
		if (this.dialogue_is_on() == false) {
			this.state_1 = 0;
			this.state_2 = 1;
		}
	} else {
		this.alpha = 1;
		if (this.try_to_talk()) {
			this.dialogue("canyon", "war");
			this.state_1 = 1;
		}
		if (this.overlaps(R.player)) {
			this.t_1++;
			if (this.t_1 > 10) {
				this.t_1 = 0;
				R.player.add_light(1);
			}
		}
	}
} else {
	this.alpha = 0.3;
}