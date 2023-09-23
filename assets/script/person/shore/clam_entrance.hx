// 80x32
// wall jumpaable i guess?
// poops down twice before permanently popping up 
// dialogue state var? 
// clam_entrnace
if (!this.child_init) {
	this.child_init = true;
	this.wall_climbable = true;
	this.s1 = 1;
	this.immovable = true;
	this.has_trigger = true;
	this.make_trigger(this.x - 32, this.y, 16, 32);
	if (this.get_ss("shoreplace", "clam_entrance", 1) == 1) {
		this.s1 = -1;
		this.y -= 32;
		return;
	}
	
}

if (this.s1 == 1 && this.doff()) {
	this.x -= 4;
	if (this.try_to_talk(0, this.trigger, false)) {
		this.dialogue("shoreplace", "clam_entrance", 0);
	}
	this.x += 4;
	if (R.player.velocity.y > 25) {
		if (this.player_separate(this)) { 
			// up
			if (this.touching == 0x0100) {
				this.s1 = 2;
				this.play_sound("clam_1.wav");
				this.velocity.y = 50;
				this.acceleration.y = -500;
			}
		}
	}
} else if (this.s1 == 2) {
	if (this.player_separate(this)) {
		R.player.velocity.y = 0;
		R.player.y = this.y - R.player.height;
	}
	if (this.y < this.iy - 4) {
		this.velocity.y = 0;
		this.acceleration.y = 0;
		this.s1 = 3;
	}
} else if (this.s1 == 3) {
	if (R.player.velocity.y > 25) {
		if (this.player_separate(this)) {
			if (this.touching == 0x0100) {
				this.s1 = 6;
				this.play_sound("clam_2.wav");
				this.velocity.y = 50;
				this.acceleration.y = -500;
			}
		}
	}
} else if (this.s1 == 6) {
	if (this.player_separate(this)) {
		R.player.velocity.y = 0;
		R.player.y = this.y - R.player.height;
	}
	if (this.y < this.iy - 8) {
		this.velocity.y = 0;
		this.acceleration.y = 0;
		this.s1 = 7;
	}
} else if (this.s1 == 7) {
	if (R.player.velocity.y > 25) {
		if (this.player_separate(this)) {
			if (this.touching == 0x0100) {
				this.s1 = 4;
				this.play_sound("clam_3.wav");
				this.velocity.y = 50;
				this.acceleration.y = -500;
			}
		}
	}
} else if (this.s1 == 4) {
	if (this.player_separate(this)) {
		R.player.velocity.y = 0;
		R.player.y = this.y - R.player.height;
	}
	if (this.y < this.iy - 20) {
		this.velocity.y = 0;
		this.acceleration.y = 0;
		this.s1 = 5;
		this.set_ss("shoreplace", "clam_entrance", 1,1);
	}
}