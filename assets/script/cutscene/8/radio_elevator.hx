var y1 = 108;
var y2 = 71;
var y3 = 27;
// 80x32
if (!this.child_init) {
	this.child_init = true;
	this.wall_climbable = true;
	this.s1 = 0;
	this.immovable = true;
	this.state_1 = 0;
	var a = this.get_ss("ending", "elevator", 1);
	
	//this.set_ss("test", "gstate", 1, 7);
	//this.set_ss("ending","elevator", 1, 0);
	//this.make_child("gauntletblocker",false);
	//this.make_child("gauntletblocker",false);
	if (R.story_mode) {
		a = 3;
	}
	if (a == 1) {
		this.state_1 = 1;
			this.y = y1 * 16;
	} else if (a == 2) {
		this.state_1 = 2;
			this.y = y2 * 16;
	} else if (a == 3) {
		this.state_1 = 2;
			this.y = y2 * 16;
			//this.y = y3 * 16;
	}
	this.has_trigger = true;
	this.make_trigger(0, 0, 32, 48);
	
	this.animation.play("zero");
}


	if (this.s2 == 3) {
		this.recv_message("RESTORE_PLANTBLOCK");
		//this._trace("nr of light");
		//this._trace(this.nr_LIGHT_received);
		this.s2++;
	}  else if (this.s2 < 3){
		this.s2 ++;
		return;
	}

if (this.nr_LIGHT_received == 0 && this.state_1 == 0) {
	
} else if (this.nr_LIGHT_received == 3 && this.state_1 == 1) {
	
} else if (this.nr_LIGHT_received == 6 && this.state_1 == 2) {
	
} else if (this.nr_LIGHT_received == 9 && this.state_1 == 3) {
	
}  else if (this.nr_LIGHT_received % 3 == 1) {
	this.animation.play("one");
} else if (this.nr_LIGHT_received % 3 == 2) {
	this.animation.play("two");
} else if (this.nr_LIGHT_received % 3 == 0) {
	this.animation.play("three");
} else {
	
}


if (this.player_separate(this)) {
		R.player.velocity.y = 0;
		R.player.y = this.y - R.player.height;
}

this.trigger.move(this.x +this.width / 2 - this.trigger.width / 2, this.y - this.trigger.height);
if (this.state_1 == 0) {
	if (this.s1 == 0) {
		if (this.nr_LIGHT_received > 2) {
			if (this.try_to_talk(0, this.trigger, true)) {
				this.s1 = 1;
				this.set_ss("ending", "elevator", 1, 1);
				this.play_sound("Elevator.wav");
			}
		} else {
			if (this.try_to_talk(0, this.trigger, true)) {
				this.dialogue("ending", "elevator", 0);
			}
		}
		
	} else if (this.s1 == 1) {
		if (this.velocity.y > -60) this.velocity.y -= 1;
		
			this.cam_to_id(0, 1);
		if (R.player.x < this.x + 3) R.player.x = this.x + 3;
		if (R.player.x + R.player.width > this.x + this.width - 3) R.player.x = this.x + this.width - 3 - R.player.width;
		if (this.y < y1 * 16) {
			this.y = y1 * 16;
			this.velocity.y = 0;
			if (R.player.touching & 0x1000 > 0) {
				R.player.last.y = this.y - R.player.height;
				R.player.y = R.player.last.y + 1;
			}
			this.s1 = 0;
			this.state_1 = 1;
			this.animation.play("fade");
			this.play_sound("raisewall_fall.wav");
		}
		
	}
	
} else if (this.state_1 == 1) {
	if (this.s1 == 0) {
		
		if (this.nr_LIGHT_received > 5) {
			if (this.try_to_talk(0, this.trigger, true)) {
				this.s1 = 1;
				this.set_ss("ending", "elevator", 1,2);
				this.play_sound("Elevator.wav");
			}
		} else {
			if (this.try_to_talk(0, this.trigger, true)) {
				this.dialogue("ending", "elevator", 0);
			}
		}
		
	} else if (this.s1 == 1) {
			this.cam_to_id(0, 1);
			
		if (this.velocity.y > -60) this.velocity.y -= 1;
		if (R.player.x < this.x + 3) R.player.x = this.x + 3;
		if (R.player.x + R.player.width > this.x + this.width - 3) R.player.x = this.x + this.width - 3 - R.player.width;
		if (this.y < y2 * 16) {
			this.y = y2 * 16;
			this.velocity.y = 0;
			this.s1 = 0;
			this.state_1 = 2;
			this.animation.play("fade");
			this.play_sound("raisewall_fall.wav");
			if (R.player.touching & 0x1000 > 0) {
				R.player.last.y = this.y - R.player.height;
				R.player.y = R.player.last.y + 1;
			}
			//this.nr_LIGHT_received = 0;
		}
	}
} else if (this.state_1 == 2) {
	if (this.s1 == 0) {
	
		if (this.nr_LIGHT_received > 8) {
			if (this.try_to_talk(0, this.trigger, true)) {
				//this.nr_LIGHT_received = 0;
				this.s1 = 1;
				this.set_ss("ending", "elevator", 1,3);
				this.play_sound("Elevator.wav");
			}
		} else {
			if (this.try_to_talk(0, this.trigger, true)) {
				this.dialogue("ending", "elevator", 0);
			}
		}
		
		
	} else if (this.s1 == 1) {
		
		if (this.velocity.y > -60) this.velocity.y -= 1;
			this.cam_to_id(0, 1);
		if (R.player.x < this.x + 3) R.player.x = this.x + 3;
		if (R.player.x + R.player.width > this.x + this.width - 3) R.player.x = this.x + this.width - 3 - R.player.width;
		if (this.y < y3 * 16) {
			this.y = y3 * 16;
			this.velocity.y = 0;
			this.s1 = 0;
			this.state_1 = 3;
			this.animation.play("fade");
			this.play_sound("raisewall_fall.wav");
			if (R.player.touching & 0x1000 > 0) {
				R.player.last.y = this.y - R.player.height;
				R.player.y = R.player.last.y + 1;
			}
			//this.nr_LIGHT_received = 0;
		}
	}
}