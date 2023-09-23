//{ falls_npc
if (!this.child_init) {
	this.child_init = true;
	this.s1 = 0;
	this.s2 = 0;
	var dark_ss = this.get_ss("falls", "npc", 1);
	var light_ss = this.get_ss("falls", "npc", 2);
	if (this.context_values[0] == 0) {
		if (dark_ss & 0x1 > 0) this.s1 = -1;
		this.animation.play("4");
	} else if  (this.context_values[0] == 1) {
		if (dark_ss & 0x10 > 0) this.s1 = -1;
		this.animation.play("5");
	} else if  (this.context_values[0] == 2) {
		if (dark_ss & 0x100 > 0) this.s1 = -1;
		this.animation.play("6");
	}  else if  (this.context_values[0] == 3) {
		if (dark_ss & 0x1000 > 0) this.s1 = -1;
		this.animation.play("7");
	}  else if (this.context_values[0] == 10) {
		if (light_ss & 0x1 > 0) this.s1 = -1;
		this.animation.play("0");
	}  else if (this.context_values[0] == 11) {
		if (light_ss & 0x10 > 0) this.s1 = -1;
		this.animation.play("1");
	}  else if (this.context_values[0] == 12) {
		if (light_ss & 0x100 > 0) this.s1 = -1;
		this.animation.play("2");
	}  else if (this.context_values[0] == 13) {
		if (light_ss & 0x1000 > 0) this.s1 = -1;
		this.animation.play("3");
	}
	
	if (this.s1 == -1) {
		this.visible = false;
	}
}

if (this.s1 == 0) {
	if (this.try_to_talk(0, this)) {
		var i = this.context_values[0];
		var dark_ss = this.get_ss("falls", "npc", 1);
		if (i == 0 ) {
			this.dialogue("falls", "npc", 0);
			dark_ss = dark_ss | 0x1;
		} else if (i == 1) {
			this.dialogue("falls", "npc", 1);
			dark_ss = dark_ss | 0x10;
		} else if (i == 2) {
			this.dialogue("falls", "npc", 2);
			dark_ss = dark_ss | 0x100;
		}else if (i == 3) {
			this.dialogue("falls", "npc", 3);
			dark_ss = dark_ss | 0x1000;
		}
		this.set_ss("falls", "npc", 1, dark_ss);
		
		var light_ss = this.get_ss("falls", "npc", 2);
		if (i == 10) {
			this.dialogue("falls", "npc", 4);
			light_ss = light_ss | 0x1;
		} else if (i == 11) {
			this.dialogue("falls", "npc", 5);
			light_ss = light_ss | 0x10;
		} else if (i == 12) {
			this.dialogue("falls", "npc", 6);
			light_ss = light_ss | 0x100;
		}else if (i == 13) {
			this.dialogue("falls", "npc", 7);
			light_ss = light_ss | 0x1000;
		}
		this.set_ss("falls", "npc", 2, light_ss);
		this.s1 = 10;
	}
} else if (this.s1 == 10 && this.doff()) {
	this.s1 = 11;
	if (this.x < R.player.x) {
		this.velocity.x = 50;
		this.acceleration.x = 300;
	} else {
		this.velocity.x = -50;
		this.acceleration.x = -300;
	}
	this.dialogue("falls", "npc", 8);
} else if (this.s1 == 11) {
	this.scale.x -= 0.07;
	this.scale.y -= 0.07;
	if (this.scale.x <= 0) {
		this.scale.set(0, 0);
		this.velocity.x = 0;
		this.acceleration.x = 0;
	}
	if (this.doff() && this.scale.x <= 0) {
		this.s1 = 1;
	}
} else if (this.s1 == 1) {
	
	this.s1 = 2;
	var dark_score = 0;
	var dark_ss = this.get_ss("falls", "npc", 1);
	if (dark_ss & 0x1 > 0) dark_score++;
	if (dark_ss & 0x10 > 0) dark_score++;
	if (dark_ss & 0x100 > 0) dark_score++;
	if (dark_ss & 0x1000 > 0) dark_score++;
	
	var light_score = 0;
	dark_ss = this.get_ss("falls", "npc", 2);
	if (dark_ss & 0x1 > 0) light_score ++;
	if (dark_ss & 0x10 > 0) light_score ++;
	if (dark_ss & 0x100 > 0) light_score ++;
	if (dark_ss & 0x1000 > 0) light_score ++;
	
	if (dark_score + light_score > 0 && 0 == this.get_ss("falls", "falls_state", 1)) {
			this.set_ss("falls", "falls_state", 1, 1);
			this.s1 = 2;
			this.dialogue("falls", "npc", 9);
	} else if (dark_score + light_score >= 4) {
		if (0 == this.get_ss("falls", "falls_state", 2)) {
			this.set_ss("falls", "falls_state", 2, 1);
			this.s1 = 2;
			this.dialogue("falls", "npc", 10);
		}
	}
	
} else if (this.s1 == 2 && this.doff()) {
	this.s1 = -1;
}
