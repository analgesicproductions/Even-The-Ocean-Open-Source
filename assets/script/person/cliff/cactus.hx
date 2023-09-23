if (!this.child_init) {
	this.child_init = true;
	
	
	//this._trace("cactus debug");
	//R.story_mode = true;
	//this.set_ss("cliff", "incense", 1, 1);
	
	this.make_child("cliff_spore", false, "idle");
	this.make_child("cliff_cactus", false, "back");
	this.make_child("cliff_cactus", false, "front",true);
	
	R.player.enter_main_state();
	
	
	this.has_trigger = true;
	this.make_trigger(this.x, this.y,8,8);
	
	this.s1 = 0;
	this.set_vars(this.sprites.members[1], this.x, this.y, 1);
	this.set_vars(this.fg_sprites.members[0], this.x, this.y, 1);
	this.only_visible_in_editor = true;
	
	if (this.event(18)) {
		this.s1 = -1;
	}
}

var spore = this.sprites.members[0];
var cactus = this.sprites.members[1];
var cage = this.fg_sprites.members[0];


if (this.s1 == 0 || this.s1 == -1) {
	
	cage.move(cactus.x, cactus.y);
	cage.offset.y = cactus.offset.y;
	cage.height = cactus.height;
	
	cactus.height = 2;
	cactus.y -= 2;
	cactus.offset.y = 46;
	cactus.allowCollisions = 0x0100;
	cactus.immovable = true;
	if (this.s1 == -1) {
		if (this.player_separate(cactus)) {
			
		}

		cactus.y += 2;
		return;
	}
	this.s1 = 1;
	this.trigger.x = this.x + 8;
	this.trigger.y = this.y - 18;
} else if (this.s1 == 1) {
	if (this.doff()) {
		if (this.player_separate(cactus)) {
			if (this.try_to_talk(0, this.trigger, true)) {
				this.dialogue("cliff", "cliff_scene", 3);
				this.s1 = 2 ;	
			}
		} else {
			this.try_to_talk(1, this.trigger, true);
		}
	}
} else if (this.s1 == 12341) {
	if (this.doff()) {
		this.s1 = 1;
		this.dialogue("cliff", "cliff_scene", 4);
	}
} else if (this.s1 == 2) {
	if (this.d_last_yn() > -1) {
		if (0 == this.d_last_yn()) {
			R.player.enter_cutscene();
			R.player.animation.play("sit_down_r");
			this.s1 = 3;
			this.set_vars(spore, this.camera_edge(true, false, true) - 48, cactus.y - 64, 1);
			spore.velocity.y = 0;
			spore.ID = 0;
		} else {
			this.s1 = 1;
		}
	}
} else if (this.s1 == 3) {
	
	R.player.y = R.player.last.y = cactus.y - R.player.height;
	R.player.acceleration.y = 0;
	this.t_2 ++;
	if (this.t_2 < 90) {
		return;
	}
	if (spore.ID == 0) {

			spore.velocity.x = 100;
		spore.velocity.y += 3;
		if (spore.velocity.y > 30) {
			spore.ID = 1;
		}
	} else if (spore.ID == 1) {
		spore.velocity.y -= 3;
		if (spore.velocity.y < -30) {
			spore.ID = 0;
		}
	}
	if (spore.x + spore.width / 2 > cactus.x - 1 + cactus.width / 2) {
		spore.velocity.x = 0;
		spore.x = cactus.x;
		this.t_1 ++;
		if (this.t_1 > 60) {
			this.s1 = 4;
			this.t_1 = this.t_2 = 0;
			spore.velocity.y = 10;
			spore.animation.play("close");
		}
	}
	
} else if (this.s1 == 4) {
	
	R.player.y = R.player.last.y = cactus.y - R.player.height;
	
	R.player.acceleration.y = 0;
	if (spore.y + spore.height > cactus.y - (32 - 5)) {
		spore.velocity.y = -80;
		R.player.acceleration.y = 0;
		cactus.velocity.y = -80;
		this.s1 = 5;
	}
} else if (this.s1 == 5) {
	this.t_1 ++;
	
	
	
	R.player.y = R.player.last.y = cactus.y - R.player.height;
	R.player.acceleration.y = 0;
	if (this.t_1 == 60) {
		// item check
		//R.player.enter_main_state();
		spore.velocity.y = 0;
		cactus.velocity.y = 0;
		this.dialogue("cliff", "cliff_scene", 6);
		//spore.acceleration.y = 350;
	} else if (this.t_1 > 60 && this.t_1 < 120) {
		if (spore.ID == 0) {
			//spore.velocity.y += 5;
			//if (spore.velocity.y > 30) {
				//spore.ID = 1;
			//}
		} else if (spore.ID == 1) {
			//spore.velocity.y -= 5;
			//if (spore.velocity.y < -30) {
				//spore.ID = 0;
			//}
		}
		if (this.doff()) {
			
		} else if (this.t_1 == 119) {
			this.t_1 = 118;
		}
	} else if (this.t_1 == 120) {
		
		if (1 == this.get_ss("cliff","incense",1)) {
			spore.velocity.x = -150;
			
			R.player.pause_toggle(false); 
			R.player.velocity.x = -150;
			cactus.velocity.x = -150;
			spore.velocity.y = 0;
			this.s1 = 7;
		} else {
			spore.animation.play("open");
			spore.velocity.y = -80;
			R.player.enter_main_state();
			cactus.acceleration.y = 350;
			this.s1 = 6;
		}
	}
} else if (this.s1 == 6) {
		this.s1 = 10;
} else if (this.s1 == 10) {
	if (cactus.y > this.iy - 2) {
		cactus.y = this.iy;
		cactus.velocity.y = 0;
		cactus.acceleration.y = 0;
	}
	
	if (R.player.is_on_the_ground(true)) {
		this.dialogue("cliff", "cliff_scene", 5);
		this.s1 = 11;
	}
} else if (this.s1 == 11) {
	
	if (cactus.y > this.iy - 2) {
		cactus.y = this.iy;
		cactus.velocity.y = 0;
		cactus.acceleration.y = 0;
		
		if (this.doff()) {
			this.s1 = 1;
			spore.velocity.y = 0;
			spore.animation.play("idle");
		}
	}
	
} else if (this.s1 == 7) {
	
	
	
	R.player.y = R.player.last.y = cactus.y - R.player.height;
	R.player.acceleration.y = 0;
	if (R.player.x < 2700) {
		spore.velocity.set(0, 0);
		cactus.velocity.x = 0;
		cactus.velocity.y = 0;
		R.player.velocity.x = 0;
		R.player.velocity.y = 0;
		this.dialogue("cliff", "cliff_scene", 8);
		this.s1 = 8;
	}
} else if (this.s1 == 8) {
	
	
	R.player.y = R.player.last.y = cactus.y - R.player.height;
	R.player.acceleration.y = 0;
	if (this.doff()) {
			//R.player.velocity.x = -150;
			//cactus.velocity.x = -150;
	
	if (R.player.x < 2700) {
		if (R.story_mode) {
			this.change_map("CLIFF_B", 3, 119, true);
		} else {
			this.change_map("CLIFF_G1", 3, 18, true);
		}
		R.player.pause_toggle(true);
		R.player.enter_main_state();
		//R.player.x += 1;
		this.s1 = 9;
	}
	}
} else if (this.s1 == 9) {
	R.player.velocity.set(0, 0);
	cactus.velocity.x = 0;
	spore.velocity.x = 0;
	spore.velocity.y = 0;
	R.player.y = R.player.last.y = cactus.y - R.player.height - 2;
}

if (this.s1 == 8 || this.s1 == 7) {
	spore.y = -spore.height + cactus.y - (32 - 5);
	if (cactus.y > 64) {
		cactus.y -= 1;
	}
	if (spore.ID == 0) {
		//spore.velocity.y += 5;
		//if (spore.velocity.y > 30) {
			//spore.ID = 1;
		//}
	} else if (spore.ID == 1) {
		//spore.velocity.y -= 5;
		//if (spore.velocity.y < -30) {
			//spore.ID = 0;
		//}
	}
}


cage.move(cactus.x, cactus.y);
cage.offset.y = cactus.offset.y;
cage.height = cactus.height;
cage.velocity.set(cactus.velocity.x, cactus.velocity.y);