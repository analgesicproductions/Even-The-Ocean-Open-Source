if (!this.child_init) {
	this.child_init = true;
	// parent of 3 Spores
	// One trigger, near the cliff
	// moves to further away 
	
	// use wf outside scene for camera help
	this.s1 = 0;
	this.s2 = 0;

	//this._trace("DEBUG cliff chase control");
	//this.s1 = 4;
	//this.set_ss("cliff", "cliff_scene", 1, 0);
	
	this.only_visible_in_editor = true;
	if (this.get_ss("cliff", "cliff_scene", 1) == 1) {
		this.SCRIPT_OFF = true;
		return;
	}
	
	this.has_trigger = true;
	this.make_trigger(this.x, this.y-68, 20, 100);
	
	this.make_child("cliff_golem_scene",false,"idle");
	this.make_child("cliff_spore",false,"idle");
	this.make_child("cliff_spore",false,"idle");
	this.make_child("cliff_spore",false,"idle");
	
	
	
}

var golem = this.sprites.members[0];
var spore1 = this.sprites.members[1];
var spore2 = this.sprites.members[2];
var spore3 = this.sprites.members[3];


var spd = 40;
if (this.s1 == 0) {
	if (R.player.overlaps(this.trigger)) {
		R.player.velocity.x = 0;
		
		if (this.player_freeze_help())  {
			this.s1 = 2; // EAE now happens at anetnrance
			
			this.dialogue("cliff", "cliff_scene", 0);
			//this.energy_bar_move_set(false,true);
			//this.dialogue("cliff",
		}
		
	}
} else if (this.s1 == 1) {
	
} else if (this.s1 == 2 && this.doff()) {
	R.player.enter_cutscene();
	R.easycutscene.start("3j_airgeome");
	this.s1 = 3;
	
} else if (this.s1 == 3 && R.easycutscene.is_off()) {
	this.dialogue("cliff", "cliff_scene", 9);
	this.s1 = 4;
} else if (this.s1 == 4 && this.doff()) {
	R.player.enter_main_state();
	//this.camera_to_player(true);
	this.s1 = 5;
	R.set_flag_bitwise(49, 1 << 8);
	this.set_ss("cliff", "cliff_scene", 1, 1);
	this.trigger.x += 70;
	
	R.there_is_a_cutscene_running = false;
	this.energy_bar_move_set(true);
}

if (this.s1 >= 0 && this.s1 <= 5) {
	if (R.player.x <= 1072) {
		R.player.x = 1072;
	}
	
}

if (this.s1 == 5) {
	if (R.player.overlaps(this.trigger)) {
		this.dialogue("cliff", "cliff_scene", 1);
		this.s1 = 6;
	}
} else if (this.s1 == 6 && this.doff()) {
	this.set_vars(spore1, this.x + 32, this.y, 1);
	spore1.width = spore1.height = 16;
	spore1.offset.set(8, 8);
	spore1.x = this.camera_edge();
	spore1.y = this.camera_edge(false, true) - 140;
	this.s1 = 7;
} else if (this.s1 == 7) {
	var accel = 30;
	var mxspd = 220;
	if (spore1.x < R.player.x + 5) {
		if (spore1.velocity.x < mxspd ) {
			spore1.velocity.x += accel;
		}
	} else {
		if (spore1.velocity.x > -mxspd ) {
			spore1.velocity.x -= accel;
		}
	}
	if (spore1.y < R.player.y + 10) {
		if (spore1.velocity.y < mxspd ) {
			spore1.velocity.y += accel;
		}
	} else {
		if (spore1.velocity.y > -mxspd ) {
			spore1.velocity.y -= accel;
		}
	}
	if (spore1.overlaps(R.player)) {
		spore1.velocity.set(0, 0);
		R.player.animation.play("fll");
		R.player.touching = 0;
		R.player.y -= 6;
		R.player.last.y -= 6;
		
		
		spore1.x = R.player.x - 2;
		spore1.y = R.player.y - 18;
		spore1.animation.play("close");
		
		this.s1 = 8;
		this.dialogue("cliff", "cliff_scene", 2);
	}
} else if (this.s1 == 8 && this.doff()) {
	R.player.x = spore1.x + 2;
	R.player.y = spore1.y + 18;
	R.player.velocity.y = 0;
	if (spore1.velocity.x > -100) {
		spore1.velocity.x -= 10;
	}
	if (R.input.jpLeft || R.input.jpRight) {
		this.s3 ++;
		if (this.s3 > 10) {
			this.s3 = 0;
		spore1.animation.play("open");
			this.s1 = 9;
		}
	}
	if (spore1.x < 900) {
		this.s1 = 10;
		spore1.velocity.y = -30;
	} else {
		if (spore1.y < 220) {
			var spore = spore1;
			if (spore.ID == 0) {
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
			
		} else {
			spore1.ID = 0;
			spore1.velocity.y = -80;
		}
	}

}

if (this.s1 == 10) {
	spore1.velocity.x = 0;
	this.t_1 ++;
	if (this.t_1 == 60) {
		spore1.velocity.y = 150;
		R.player.velocity.y = 400;
		spore1.animation.play("open");
	} else if (this.t_1 == 100) {
		spore1.velocity.y = 0;
	} else if (this.t_1 < 60) {
		R.player.x = spore1.x + 2;
		R.player.y = spore1.y + 18;
		R.player.velocity.y = 0;
	}
}

if (this.s1 == 9) {
	this.t_1++;
	if (this.t_1 > 120) {
		this.set_vars(spore2, this.x + 32, this.y, 1);
		spore2.width = spore2.height = 16;
		spore2.offset.set(8, 8);
		spore2.x = this.camera_edge() - 230;
		spore2.y = this.camera_edge(false, true, true, false) - 48;
		this.s1 = 11;
		this.t_1 = 0;
	}
} else if (this.s1 == 11) {
	
	
	var accel = 50;
	var mxspd = 320;
	if (spore2.x < R.player.x + 5) {
		if (spore2.velocity.x < mxspd) {
			spore2.velocity.x += accel;
		}
	} else {
		if (spore2.velocity.x > -mxspd) {
			spore2.velocity.x -= accel;
		}
	}
	if (spore2.y < R.player.y + 10) {
		if (spore2.velocity.y < mxspd) {
			spore2.velocity.y += accel;
		}
	} else {
		if (spore2.velocity.y > -mxspd) {
			spore2.velocity.y -= accel;
		}
	}
	
	
	if (spore2.overlaps(R.player)) {
		
		R.player.animation.play("fll");
		R.player.touching = 0;
		R.player.y -= 6;
		R.player.last.y -= 6;
		spore2.x = R.player.x - 2;
		spore2.y = R.player.y - 18;
		spore2.animation.play("close");
		spore1.animation.play("close");
		
		spore2.velocity.set(0, 0);
		this.s1 = 12;
		this.s3 = 0;
	}
	
} else if (this.s1 == 12) {
	
	R.player.x = spore2.x + 2;
	R.player.y = spore2.y + 18;
	R.player.velocity.y = 0;
	if (spore2.velocity.x > -100) {
		spore2.velocity.x -= 10;
	}
	if (R.input.jpLeft || R.input.jpRight) {
		this.s3 ++;
		if (this.s3 > 15) {
			this.s3 = 0;
			this.s1 = 13;
		spore2.animation.play("open");
		}
	}
	if (spore2.x < 900) {
		this.s1 = 10;
		spore1.x = spore2.x;
		spore1.y = spore2.y;
		spore2.exists = false;
		spore1.velocity.y = -30;
	} else {
		if (spore2.y < 220) {
			var spore = spore2;
			if (spore.ID == 0) {
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
			
		} else {
			spore2.ID = 0;
			spore2.velocity.y = -80;
		}
	}
	
	
	
} else if (this.s1 == 13) {
	this.t_1 ++;
	if (this.t_1 > 120) {
		this.set_vars(spore1, this.x + 32, this.y, 1);
		spore1.x = this.camera_edge();
		spore1.y = this.camera_edge(false, true) - 140;
		
		this.set_vars(spore2, this.x + 32, this.y, 1);
		spore2.x = this.camera_edge() - 230;
		spore2.y = this.camera_edge(false, true, true, false) - 48;
		
		
		spore2.animation.play("idle");
		spore1.animation.play("idle");
		
		this.set_vars(spore3, this.x + 32, this.y, 1);
		spore3.width = spore3.height = 16;
		spore3.offset.set(8, 8);
		spore3.x = this.camera_edge(true, false, true, false) - 48;
		spore3.y = this.camera_edge(false, true) - 140;
		this.s1 = 14;
		this.t_1 = 0;
			spore3.ID = -1;
	}
} else if (this.s1 == 14) {
	// 3 spore chase
	
	var accel = 35;
	var mxspd = 250;
	if (spore1.x < R.player.x - 8) {
		if (spore1.velocity.x < mxspd ) {
			spore1.velocity.x += accel;
		}
	} else {
		if (spore1.velocity.x > -mxspd ) {
			spore1.velocity.x -= accel;
		}
	}
	if (spore1.y < R.player.y + 2) {
		if (spore1.velocity.y < mxspd ) {
			spore1.velocity.y += accel;
		}
	} else {
		if (spore1.velocity.y > -mxspd ) {
			spore1.velocity.y -= accel;
		}
	}
	
	if (spore2.x < R.player.x - 8) {
		if (spore2.velocity.x < mxspd) {	spore2.velocity.x += accel; }
	} else {
		if (spore2.velocity.x > -mxspd) {
			spore2.velocity.x -= accel;
		}
	}
	if (spore2.y < R.player.y + 2) {
		if (spore2.velocity.y < mxspd) {
			spore2.velocity.y += accel;
		}
	} else {
		if (spore2.velocity.y > -mxspd) {
			spore2.velocity.y -= accel;
		}
	}

	if (spore3.x < R.player.x + 5) {
		if (spore3.velocity.x < mxspd) {	spore3.velocity.x += accel; }
	} else {
		if (spore3.velocity.x > -mxspd) {
			spore3.velocity.x -= accel;
		}
	}
	
	if (spore3.ID == -1) {
		if (spore3.y < R.player.y + 10) {
			if (spore3.velocity.y < mxspd) {
				spore3.velocity.y += accel;
			}
		} else {
			if (spore3.velocity.y > -mxspd) {
				spore3.velocity.y -= accel;
			}
		}
	} 
	
	if (spore3.overlaps(R.player) || this.s3 == 1) {
		
		// Latch onto the player
		if (this.s3 == 0) {
			R.player.animation.play("fll");
			R.player.touching = 0;
			R.player.y -= 6;
			R.player.last.y -= 6;
			spore3.animation.play("close");
			spore3.x = R.player.x - 2;
			spore3.y = R.player.y - 18;
			
			this.s3 = 1;
		}
		
		spore3.velocity.x = -100;
		// when far enough left, push down
		if (spore3.x < 900) {
			spore3.velocity.x = 0;
			this.t_1++;
			if (this.t_1 < 60) {
				R.player.x = spore3.x + 2;
				R.player.y = spore3.y + 18;
				R.player.velocity.y = 0;
				spore3.velocity.y = -10;
			} else if (this.t_1 < 90) {
				spore3.velocity.y = 200;
				R.player.velocity.y = 300;
				
				this.s1 = 15;
				
			} else {
				R.player.velocity.y = 300;
			}
		} else {
			R.player.x = spore3.x + 2;
			R.player.y = spore3.y + 18;
			R.player.velocity.y = 0;
			//this._trace(spore3.ID);
			
			if (spore3.ID == -1 && spore3.y < 220) {
				spore3.ID = 0;
			}
			
			// spore raises you up
			if (spore3.y < 220 || spore3.ID > -1) {
				if (spore3.ID == 0) {
					spore3.velocity.y += 3;
					if (spore3.velocity.y > 30) {
						spore3.ID = 1;
					}
				} else if (spore3.ID == 1) {
					spore3.velocity.y -= 3;
					if (spore3.velocity.y < -30) {
						spore3.ID = 0;
					}
				}
				
			} else {
				spore3.velocity.y = -80;
			}
			
		}
	}
} else if (this.s1 == 15) {
	this.t_1++;
	if (this.t_1 >= 90) {
		this.t_1 = 0;
		spore3.velocity.set(0, 0);
		spore2.velocity.set(0, 0);
		spore1.velocity.set(0, 0);
	}
}		