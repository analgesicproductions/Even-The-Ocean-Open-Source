if (!this.child_init) { 
	this.child_init = true;
	this.make_child("forest_memory_npc",false,"young_dolly"); // Younger dolly
	this.make_child("forest_memory_npc",false,"vale"); // vale
	this.make_child("forest_memory_npc",false,"dolly"); // Dolly 
	this.make_child("forest_memory_npc",false,"tracy"); // Tracy
	this.make_child("forest_memory_coin", false, "idle"); // Coin
	this.make_child("basin_fountain", false, "frozen"); // Coin
	if (R.inventory.is_item_found(47)) {
			this.children[0].alpha = 1;
		this.sprites.members[5].animation.play("cracked");
	} else {
			this.children[0].alpha = 0;
		this.sprites.members[5].animation.play("frozen");
	}
	
	this.set_vars(this.sprites.members[5], this.x + 64, this.y - 32, 1, true);
	
	//this.set_ss("forest", "aliph_lift", 1, 1);
	//this._trace("DEBUG FOREST");
	
	if (1 == this.get_ss("forest", "aliph_lift", 1)) {
		this.s3 = 1;
	} else {
		this.s3 = 0;
	}
	
	
	for (ii in [1,2,3,4]) {
		this.children[ii].alpha = 0;
	}
}	

var young_dolly = this.sprites.members[0];
var vale = this.sprites.members[1];
var dolly = this.sprites.members[2];
var tracy = this.sprites.members[3];
var coin = this.sprites.members[4];
var fountain = this.sprites.members[5];
fountain.alpha = 0;

// child 0 is crack
// child 1 to 4 is water (off when not in cutsceneo)

if (this.s1 == 100) {
	if (this.doff()) {
		this.s1 = 0;
		if (R.inventory.is_item_found(47)) {
			this.children[0].alpha = 1;
			this.sprites.members[5].animation.play("cracked");
		} else {
			this.children[0].alpha = 0;
			this.sprites.members[5].animation.play("frozen");
		}
	}
}

if (this.doff() && this.try_to_talk(0, fountain, true)) {
	this.dialogue("forest", "find_key", 0);
	this.s1 = 100;
}

if (this.s3 == 0) {
	this.visible = false;
	return;
}

if (this.s1 == 0) {
	if (this.s2 == 0 || this.s2 == 10) {
		this.t_1++;
		if (this.t_1 >= 120) {
			this.t_1 = 0;
		}
		this.alpha = 0.8 + 0.2 * this.get_sin(this.t_1 * 3);
	}
	if (this.s2 == 0) {
		if (this.try_to_talk()) {
			this.s2 = 10;
			this.dialogue("forest", "young_memory", 13);
		} 
	} else if (this.s2 == 10) {
		if (this.d_last_yn() != -1) {
			if (1 == this.d_last_yn()) {
				R.player.pause_toggle(true);
				R.player.velocity.x = 0;
				this.s2 = 1;
			} else {
				this.s2 = 0;
			}
		}
		
	} else if (this.s2 == 1) {
		
				R.player.pause_toggle(true);
				R.player.velocity.x = 0;
		if (this.fade_out(this) && 	this.fade_out(R.player) && this.fade_out(this.children[0])) {
			var bb = false;
			for (ii in [1,2,3,4]) {
				bb = this.fade_in(this.children[ii]);
			}
			if (bb) {
			this.s1 = 1;
			this.t_1 = 30;
			this.s2 = 0;
			fountain.animation.play("flowing");
			this.set_vars(vale, this.x - 16, this.y, 0, true);
			vale.scale.x = -1;
			dolly.scale.x = -1;
			this.set_vars(young_dolly, this.x + 32, this.y, 0, true);
			}
		}
	}
} else if (this.s1 == 1) {
	if (this.fade_in([vale,young_dolly])) {
		this.s1 = 2;
	}
} else if (this.s1 == 2) {
	if (this.s2 == 0) {
		this.dialogue("forest", "young_memory", 0,false);
		this.s2 = 1;
	} else if (this.s2 == 1) {
		if (this.dialogue_is_on() == false) {
			this.s2 = 2;
			this.set_vars(dolly, this.x - 16, this.y, 0, true);
			this.set_vars(tracy, this.x + 32, this.y, 0, true);
		}
	} else if (this.s2 == 2) {
		
		for (ii in [1,2,3,4]) {
			bb = this.fade_out(this.children[ii]);
		} 
		
		if (this.fade_out([vale, young_dolly])) {
			this.s2 = 0;
			this.s1 = 3;
		}
		dolly.alpha = 1 - vale.alpha;
		tracy.alpha = dolly.alpha;
		
	}
} else if (this.s1 == 3) {
	if (this.s2 == 0) {
		this.dialogue("forest", "young_memory", 14,false);
		this.s2 = 1;
	} else if (this.s2 == 1) {
		if (this.dialogue_is_on() == false) {
			this.s2 = 2;
			this.set_vars(coin, dolly.x + dolly.width / 2, dolly.y + dolly.height / 2, 1, true);
			coin.velocity.set( 110, -200);
			coin.acceleration.y = 350;
			this.play_sound("pop.ogg");
		}
	} else if (this.s2 == 2) {
		if (this.fade_out(coin, 0.008, 0.99)) {
			this.s2 = 3;
			this.dialogue("forest", "young_memory", 11, false);
			R.player.energy_bar.allow_move = true;
		}
	} else if (this.s2 == 3) {
		if (this.dialogue_is_on() == false) {
			this.s2 = 4;
		}
	} else if (this.s2 == 4) {
		if (R.inventory.is_item_found(47)) {
			this.fade_in(this.children[0]);
		}
		if (this.fade_out([dolly, tracy]) && this.fade_in(this) && this.fade_in(R.player)) {
			
			
			var bb = true;
			if (bb) {
			
			this.s2 = 0;
			this.s1 = 0;
			R.player.pause_toggle(false);
			R.there_is_a_cutscene_running = false;
			
			if (R.inventory.is_item_found(47)) {
			this.children[0].alpha = 1;
				fountain.animation.play("cracked");
			} else {
			this.children[0].alpha = 0;
				fountain.animation.play("frozen");
			}
			}
		}
	}
}
	