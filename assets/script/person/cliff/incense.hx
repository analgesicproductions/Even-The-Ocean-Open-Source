//{ incense
//script s "person/cliff/incense.hx"
//}
if (!this.child_init) {
	this.child_init = true;
	this.only_visible_in_editor = true;
	this.s1 = 0;
	this.s2 = 0;
	
	/* [Debug function description] */
	//this._trace("DEBUG IN 4f_paxton");
	//this.set_event(34, true, 4);
	
	/* Make sprites */
	this.make_child("cliff_guy",false);
	this.make_child("incense_npc",false);
	this.make_child("incense_npc",false);
	this.make_child("incense_npc",false);
	this.make_child("incense_glow",false,"",true);
	this.make_child("incense_glow",false,"",true);
	this.make_child("incense_glow",false,"",true);
	
	/* Check for dialogue flag */
	if (this.get_ss("cliff", "incense", 1) == 0) {
		this.s3 = 0;
		this.s1 = -1;
		this.state_1 = 0;
		this.s2 = 0;
		this.state_2 = 0;
		
		// Don't play default (cliffambient) till finished here.
		this.play_music("cliffquiet");
		//this.s1 = 7;
	} else {
		this.s1 = -1;
		this.s3 = 1;
	}
	
	this.t_2 = 0;
	
	
}

// Assign sprites
var guy = this.sprites.members[0];
var i1 = this.sprites.members[1];
var i2= this.sprites.members[2];
var i3 = this.sprites.members[3];
var g1 = this.fg_sprites.members[0];
var g2= this.fg_sprites.members[1];
var g3 = this.fg_sprites.members[2];


this.t_2 ++;
if (this.t_2 >= 360) this.t_2 = 0;
g1.scale.x = g1.scale.y = 1 + 0.05*this.get_sin(((this.t_2+60) % 360));
g2.scale.x = g2.scale.y = 1 + 0.05*this.get_sin(((this.t_2+140) % 360));
g3.scale.x = g3.scale.y = 1 + 0.05*this.get_sin(((this.t_2) % 360));

g1.move(i1.x - 48, i1.y - 64);
g2.move(i2.x - 48, i2.y - 64);
g3.move(i3.x - 48, i3.y - 64);


if (this.s1 == -1) {
	guy.alpha = i1.alpha = i2.alpha = i3.alpha = 1;
	guy.exists = i1.exists = i2.exists = i3.exists = true;
	guy.x = this.x;
	guy.y = this.y - 10;
	
	i1.x = guy.x - 5*16;
	i2.x = guy.x + 11*16;
	i3.x = guy.x + 96;
	i1.y = i2.y = i3.y = this.y;
	
	this.set_Myblend(g1,1);
	this.set_Myblend(g2,1);
	this.set_Myblend(g3,1);
	
	this.s1 = 0;
	if (this.s3 == 1) {
		this.s1 = 9;
		this.s3 = 0;
	}
}

if (this.get_ss("cliff", "dying_person_init", 1) == 0) {
	return;
}

if (this.s3 == 0) {
	
if (this.s1 == 0) {
	if (this.doff()) {
	if (this.try_to_talk(0, i1, true)) {
		if (this.state_1 & 0x1 == 0) {
			this.s1 = 1;
			this.s2 = 0x1;
		} else {
			this.dialogue("cliff", "incense", 4);
		}
	}
	if (this.try_to_talk(0, i2, true)) {
		if (this.state_1 & 0x10 == 0) {
			this.s1 = 1;
			this.s2 = 0x10;
		} else {
			this.dialogue("cliff", "incense", 4);
		}
	}
	if (this.try_to_talk(0, i3, true)) {
		if (this.state_1 & 0x100 == 0) {
			this.s1 = 1;
			this.s2 = 0x100;
		} else {
			this.dialogue("cliff", "incense", 4);
		}
	}
	
	if (this.try_to_talk(0, guy, true)) {
		this.dialogue("cliff", "dying_person_init", 7);
	}
	
	if (this.s1 == 1) {
		if (this.state_2 == 2) {
			this.dialogue("cliff", "incense", 3);
		} else if (this.state_2 == 1) {
			this.dialogue("cliff", "incense", 3);
		} else {
			this.dialogue("cliff", "incense", 0);
		}
	}
	}
} else if (this.s1 == 1) {
	if (this.d_last_yn() > -1) {
		if (this.d_last_yn() == 0) {
			this.s1 = 2;
			this.state_1 = this.state_1 | this.s2;
			
			// animss
			if (this.s2 == 0x1) {
				//i1.alpha = 0.5;
				g1.exists = true;
			} else if (this.s2 == 0x10) {
				//i2.alpha = 0.5;
				g2.exists = true;
			} else if (this.s2 == 0x100) {
				//i3.alpha = 0.5;
				g3.exists = true;
			}
			this.play_sound("shield_md.wav");
			this.play_sound("shield_mu.wav");
			
			if (this.state_2 == 2) {
				this.s1 = 4;
			} else if (this.state_2 == 1) {
				this.s1 = 3;
			}
			
			this.state_2 ++;
			this.s2 = 0;
			R.player.enter_cutscene();
		} else {
			this.s1 = 0;
			this.s2 = 0;
		}
	}
} else if (this.s1 == 2) {
	//this.my_set_angle(guy, 90);
	this.t_1 ++;
	if (this.t_1 > 30) {
		this.t_1 = 0;
		this.s1 = 0;
		
		R.player.enter_main_state();
		this.dialogue("cliff", "incense", 1);
	}
} else if (this.s1 == 3) {
	//guy.angularVelocity = 200;
	this.t_1 ++;
	if (this.t_1 > 30) {
		this.t_1 = 0;
		this.s1 = 0;
		R.player.enter_main_state();
		this.dialogue("cliff", "incense", 2);
	}
} else if (this.s1 == 4) {
	//guy.angularVelocity = 300;
	this.t_1 ++;
	if (this.t_1 > 30) {
		this.t_1 = 0;
		this.s1 = 5;
		this.dialogue("cliff", "wakeup", 0);
	}
} else if (this.s1 == 5 && this.doff()) {
	R.player.enter_cutscene();
	R.player.pause_toggle(false); 
	
	if (R.player.x > guy.x - 10) {
		R.player.velocity.x = -90;
		R.player.animation.play("wll");
	} else {
		R.player.velocity.x = 90;
		R.player.animation.play("wrr");
	}
	this.s1 = 6;
} else if (this.s1 == 6) {
	if (R.player.x - (guy.x - 10) < 2 && R.player.x - (guy.x - 10) > -2) {
		R.player.velocity.x = 0;
		R.player.animation.play("irn");
		this.dialogue("cliff", "wakeup", 4);
		this.s1 = 7;
	}
} else if (this.s1 == 7 && this.doff()) {
	this.play_music("cliffambient",false);
	this.dialogue("cliff", "wakeup", 17);
	this.s1 = 8;
} else if (this.s1 == 8 && this.doff()) {
	
	R.TEST_STATE.cutscene_handle_signal(0, [0.01]);
	this.s1 = 100;
	this.t_1 = 0;
	
	
} else if (this.s1 == 100 && R.TEST_STATE.cutscene_just_finished(0)) {
	this.s1 = 101;
} else if (this.s1 == 101) {
	this.t_1 ++;
	if (this.t_1 > 40) {
		this.t_1 = 0;
		R.TEST_STATE.cutscene_handle_signal(2, [0.02]);
		g1.exists = g2.exists = g3.exists = false;
		this.play_sound("shield_md.wav");
		this.s1 = 102;
	}
} else if (this.s1 == 102 && R.TEST_STATE.cutscene_just_finished(2)) {
		this.s1 = 9;
		this.set_ss("cliff", "incense", 1, 1);
		R.player.facing = 0x10;
		R.player.enter_main_state();
} else if (this.s1 == 9 && this.doff()) {
	
	if (this.try_to_talk(0, i1, true)) {
			this.dialogue("cliff", "incense", 4);
	}
	if (this.try_to_talk(0, i2, true)) {
			this.dialogue("cliff", "incense", 4);
	}
	if (this.try_to_talk(0, i3, true)) {
			this.dialogue("cliff", "incense", 4);
	}
	
}
	
	
	if (this.s1 != 9) {
		if (R.player.x > 667) {
			R.player.x = 667;
		}
	}
	
}

if (this.s3 == 1) {
	
}




