//{ aloe
if (!this.child_init) {
	this.child_init = true;
	this.s1 = 0;
	
		
	if (this.context_values[0] == 1) {
		this.only_visible_in_editor = true;
		this.SCRIPT_OFF = true;
		return;
	}	
	
	//this._trace("debug batsheva");
	//this.set_ss("s3", "last_debrief", 1, 1);
	//this.set_ss("i_1", "debrief", 1, 1);
	//this.set_ss("city", "aliph_fades", 1, 1);
	//this.set_ss("overworld", "batsheva", 1, 1);
	//this.set_ss("overworld", "batsheva", 2, 1);
	
	 
	// in set 3
	if (this.get_ss("s3", "last_debrief", 1) != 0) {
		if (this.get_ss("overworld","batsheva",2) == 1) {
			this.s2 = 2;
		this.move(this.children[2].x, this.children[2].y);
		this.state_1 = this.children[2].y;
		} else {
			this.SCRIPT_OFF = true;
		}
	// in set 2
	} else if (this.get_scene_state("i_1", "debrief", 1) > 0) {
		if (this.get_ss("overworld", "batsheva", 1) == 1) {
			this.s2 = 1;	
			this.make_child("yara", false, "", true);
			this.fg_sprites.members[0].scrollFactor.set(0, 0);
			this.fg_sprites.members[0].alpha = 0;
			this.fg_sprites.members[0].exists = true;
			this.center_in_screen(this.fg_sprites.members[0]);
		this.move(this.children[1].x, this.children[1].y);
		this.state_1 = this.children[1].y;
		} else {
			this.SCRIPT_OFF = true;
		}
	// in set 1 or before
	} else if (this.get_ss("overworld","batsheva",1) == 0 && 1 == this.get_ss("city", "aliph_fades", 1)) {
		this.s2 = 0;	
		this.make_child("mapSmallPics", false, "mushroom", true);
		this.fg_sprites.members[0].scrollFactor.set(0, 0);
		this.fg_sprites.members[0].alpha = 0;
		this.fg_sprites.members[0].exists = true;
		this.center_in_screen(this.fg_sprites.members[0]);
		this.move(this.children[0].x, this.children[0].y);
		this.state_1 = this.children[0].y;
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
	this.last.x = this.x;
	this.last.y = this.y;
}


if (this.s1 == 0) {
	if (this.s3 == 0) {
		this.velocity.y = -50;
		this.animation.play("walk_u");
		this.t_1 ++;
		if (this.t_1 > 60) {
			this.s3 = 1;
			this.t_1 = 0;
			this.velocity.y = 0;
			this.animation.play("idle_u");
		}
	} else if (this.s3 == 1) {
		this.t_1 ++;
		if (this.t_1 > 60) {
			this.s3 = 2;
			this.t_1 = 0;
		}
	} else if (this.s3 == 2) {
		this.velocity.y = 50;
		this.animation.play("walk_d");
		if (this.y >= this.state_1) {
			this.y = this.state_1;
			this.velocity.y = 0;
			this.animation.play("idle_d");
			this.s3 = 3;
		}
	} else if (this.s3 == 3) {
		this.t_1 ++;
		if (this.t_1 > 60) {
			this.t_1 = 0;
			this.s3 = 0;
			
		}
		
	}
} else if (this.s1 >= 1 && this.s1 < 3) {
	this.velocity.set(0, 0);
	// DURL
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


if (this.s2 == 0) {
	if (this.s1 == 0) {
		if (this.try_to_talk()) {
			this.dialogue("overworld", "batsheva", 0);
			this.set_ss("overworld", "batsheva", 1, 1);
			this.s1 = 1;
		}
	} else if (this.s1 == 1) {
		if (this.doff()) {
			this.fg_sprites.members[0].scrollFactor.set(0, 0);
			this.s1 = 2;
			R.worldmapplayer.pause_toggle(true);
		}
	} else if (this.s1 == 2) {
		if (this.fade_in(this.fg_sprites.members[0])) {
			this.s1 = 3;
		}
	} else if (this.s1 == 3) {
		if (R.input.jp_any()) {
			this.s1 = 4;
		}
	} else if (this.s1 == 4) {
		if (this.fade_out(this.fg_sprites.members[0])) {
			this.s1 = 5;
			this.dialogue("overworld", "batsheva", 1);
		}
	} else if (this.s1 == 5 && this.doff()) {
		R.worldmapplayer.pause_toggle(false);
		this.s1 = 0;
	}
} else if (this.s2 == 1) {
	if (this.s1 == 0) {
		if (this.try_to_talk()) {
			this.dialogue("overworld", "batsheva", 2);
			this.set_ss("overworld", "batsheva", 2, 1);
			this.s1 = 1;
		}
	} else if (this.s1 == 1) {
		if (this.doff()) {
			this.fg_sprites.members[0].scrollFactor.set(0, 0);
			this.s1 = 2;
			R.worldmapplayer.pause_toggle(true);
		}
	} else if (this.s1 == 2) {
		//if (this.fade_in(this.fg_sprites.members[0])) {
			this.s1 = 3;
		//}
	} else if (this.s1 == 3) {
		//if (R.input.jp_any()) {
			this.s1 = 4;
		//}
	} else if (this.s1 == 4) {
		//if (this.fade_out(this.fg_sprites.members[0])) {
			this.s1 = 5;
			this.dialogue("overworld", "batsheva", 3);
		//}
	} else if (this.s1 == 5 && this.doff()) {
		R.worldmapplayer.pause_toggle(false);
		this.s1 = 0;
	}
	
} else if (this.s2 == 2) {
	if (this.s1 == 0) {
		if (this.try_to_talk()) {
			this.dialogue("overworld", "batsheva", 4);
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