if (!this.child_init) {
	this.child_init = true;
	this.make_child("canyon_air_spore");
	this.make_child("canyon_air_spore");
	this.make_child("canyon_air_spore");
}
if (R.inventory.is_item_found(12) == true) {
	this.alpha = 1;
	if (this.state_1 == 1) {
		if (this.dialogue_is_on() == false && this.state_2 == 0) {
			this.play_sound("air_cry_filter.ogg");
			
			for (i in [0, 1, 2]) {
				this.sprites.members[i].velocity.set( -60 + 120 * this.random(), -50 - 50 * this.random());
				this.sprites.members[i].acceleration.y = 40;
				this.sprites.members[i].move(this.x, this.y);
				this.sprites.members[i].exists = true;
				this.sprites.members[i].alpha = 1;
			}
			this.state_2 = 1;
		}
		
		if (this.state_2 == 1) {
			var j = 0;
			for (i in [0, 1, 2]) {
				this.sprites.members[i].alpha -= 0.005;
				if (this.sprites.members[i].alpha <= 0) {
					j = j + 1;
				}
			}
			if (j == 3) {
				this.state_2 = 0;
				this.state_1 = 0;
			}
		}
	} else {
		if (this.try_to_talk()) {
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