//{ aloe
if (!this.child_init) {
	this.child_init = true;
	this.s1 = 0;
	
	if (this.context_values[0] == 1) {
		this.only_visible_in_editor = true;
		this.SCRIPT_OFF = true;
		return;
	}	
	
	//this._trace("debug bob"); 
	//this.set_ss("overworld", "bob", 2, 1);
	
	//this.set_ss("i2", "cart_init", 1, 1);
	//this.set_ss("i_1", "debrief", 1, 1);
	//this.set_ss("city", "aliph_fades", 1, 1);
	
	 
	// in set 3
	if (this.get_ss("i2", "cart_init", 1) != 0) {
		if (this.get_ss("overworld","bob",2) == 1 && 0 == this.get_ss("s3","last_debrief",1)) {
			this.s2 = 2;
			this.move(this.children[2].x, this.children[2].y);
			this.state_1 = this.children[2].x;
		} else {
			this.SCRIPT_OFF = true;
		}
	// in set 2
	} else if (this.get_scene_state("i_1", "debrief", 1) > 0) {
		if (this.get_ss("overworld", "bob", 1) == 1) {
			this.s2 = 1;	
			this.move(this.children[1].x, this.children[1].y);
			this.state_1 = this.children[1].x;
		} else {
			this.SCRIPT_OFF = true;
		}
	// in set 1 or before
	} else if (this.get_ss("overworld","bob",1) == 0 && 1 == this.get_ss("city", "aliph_fades", 1)) {
		this.s2 = 0;
		this.move(this.children[0].x, this.children[0].y);
		this.state_1 = this.children[0].x;
	} else {
		this.SCRIPT_OFF = true;
	}
	
	if (this.SCRIPT_OFF) {
		this.only_visible_in_editor  = true;
		return;
	}
	
	this.width += 24;
	this.height += 24;
	this.offset.set(-12,-12);	
	this.s3 = 0;
	this.state_2 = 0;
	this.last.x = this.x;
	this.last.y = this.y;
}


// logic while not talking
if (this.s1 == 0) {
	if (this.s3 == 0) {
		this.velocity.x = -50;
		this.animation.play("walk_l");
		this.t_1 ++;
		if (this.t_1 > 60) {
			this.s3 = 1;
			this.t_1 = 0;
			this.velocity.x = 0;
			this.animation.play("idle_l");
		}
	} else if (this.s3 == 1) {
		this.t_1 ++;
		if (this.t_1 > 60) {
			this.s3 = 2;
			this.t_1 = 0;
		}
	} else if (this.s3 == 2) {
		this.velocity.x = 50;
		this.animation.play("walk_r");
		if (this.x >= this.state_1) {
			this.x = this.state_1;
			this.velocity.x = 0;
			this.animation.play("idle_r");
			this.s3 = 3;
		}
	} else if (this.s3 == 3) {
		this.t_1 ++;
		if (this.t_1 > 60) {
			this.t_1 = 0;
			this.s3 = 0;
			
		}
		
	}
} else if (this.s1 == 1) {
	this.velocity.set(0, 0);
} else {
	
}



if (this.s2 == 0) {
	if (this.s1 == 0) {
		if (this.try_to_talk()) {
			this.dialogue("overworld", "bob", 0);
			this.set_ss("overworld", "bob", 1, 1);
			this.s1 = 1;
			this.state_2 = R.worldmapplayer.facing;
			// Turn to face player
			if (R.worldmapplayer.facing == 0x1000) {
				this.animation.play("idle_u");
			} else if (R.worldmapplayer.facing == 0x0100) {
				this.animation.play("idle_d");
			} else if (R.worldmapplayer.facing == 0x0010) {
				this.animation.play("idle_l");
			} else if (R.worldmapplayer.facing == 0x0001) {
				this.animation.play("idle_r");
			} 
			
		}
	} else if (this.s1 == 1) {
		if (this.doff()) {
			this.s1 = 2;
			R.worldmapplayer.facing = this.state_2;
		}
	} else if (this.s1 == 2) {
		this.alpha -= 0.01;
		if (this.alpha <= 0) {
			this.alpha = 0;
		}
	}
} else if (this.s2 == 1) {
	if (this.s1 == 0) {
		if (this.try_to_talk()) {
			this.dialogue("overworld", "bob", 4);
			this.set_ss("overworld", "bob", 2, 1);
			this.s1 = 1;
		}
	} else if (this.s1 == 1) {
		if (this.doff()) {
			this.s1 = 0;
		}
	}
	
} else if (this.s2 == 2) {
	if (this.s1 == 0) {
		if (this.try_to_talk()) {
			this.dialogue("overworld", "bob", 6);
			this.s1 = 1;
		}
	} else if (this.s1 == 1) {
		if (this.doff()) {
			this.s1 = 0;
		}
	}
} else {
	if (this.doff()) {
		this.s1 = 0;
	}
}

if (this.alpha == 1) {
this.immovable = true;
this.width -= 16;
this.height -= 8;
this.x += 8;
this.y += 4;
this.last.x += 8;
this.last.y += 4;
this.player_separate(this);
this.x -= 8;
this.y -= 4;
this.last.x -= 8;
this.last.y -= 4;
this.width += 16;
this.height += 8;
}