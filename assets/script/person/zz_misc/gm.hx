if (!this.child_init) {
	this.child_init = true;
	
	this.make_child("gmDoorSprite", true, "rouge");
	this.make_child("gmDoorSprite", true, "fade");
	
	this.bg_sprites.members[0].move(this.x, this.y);
	this.bg_sprites.members[1].move(this.x, this.y);
	
	//this.set_Myblend(this.bg_sprites.members[1], 2);
	
	this.bg_sprites.members[0].exists = true;
	this.bg_sprites.members[1].exists = true;
	
	var gid = this.context_values[0];
	
	if (gid == 1) this.bg_sprites.members[0].animation.play("shore");
	if (gid == 2) this.bg_sprites.members[0].animation.play("canyon");
	if (gid == 3) this.bg_sprites.members[0].animation.play("hill");
		
	if (gid == 4) this.bg_sprites.members[0].animation.play("river");
	if (gid == 5) this.bg_sprites.members[0].animation.play("woods");
	if (gid == 6) this.bg_sprites.members[0].animation.play("basin");
		
	if (gid == 11) this.bg_sprites.members[0].animation.play("es");
	if (gid == 12) this.bg_sprites.members[0].animation.play("as");
	if (gid == 13) this.bg_sprites.members[0].animation.play("ss");
		
	if (gid == 7) this.bg_sprites.members[0].animation.play("pass");
	if (gid == 8) this.bg_sprites.members[0].animation.play("cliff");
	if (gid == 9) this.bg_sprites.members[0].animation.play("falls");
		
	if (gid == 14) this.bg_sprites.members[0].animation.play("radio");
	
	// debug for now
	//this.bg_sprites.members[0].animation.play("fade");
	
	this.s2 = 0;
	return;
}

var under = this.bg_sprites.members[0];
var fade = this.bg_sprites.members[1];

if (R.player.overlaps(this)) {
	fade.alpha -= 0.01;
	if (fade.alpha <= 0) {
		fade.alpha = 0.01;
	} else {
		fade.alpha *= 0.96;
	}
} else {
	fade.alpha += 0.01;
	if (fade.alpha >= 0.5) {
		fade.alpha = 0.5; 
	} else {
		fade.alpha *= 1.05;
	}
}

if (this.s1 == 0) {
	// run when startup or when try talk
	if (this.try_to_talk() || this.s2 == 0) {
		var gdone = false;
		var gid = this.context_values[0];
		gdone |= (gid == 0 && this.event(23));
		
		gdone |= (gid == 1 && this.event(9));
		gdone |= (gid == 2 && this.event(12));
		gdone |= (gid == 3 && this.event(13));
		
		gdone |= (gid == 4 && this.event(15));
		gdone |= (gid == 5 && this.event(14));
		gdone |= (gid == 6 && this.event(16));
		
		gdone |= (gid == 10 && this.event(48));
		
		gdone |= (gid == 11 && R.inventory.is_item_found(23));
		gdone |= (gid == 12 && R.inventory.is_item_found(24));
		gdone |= (gid == 13 && R.inventory.is_item_found(25));
		
		gdone |= (gid == 7 && this.event(17));
		gdone |= (gid == 8 && this.event(18));
		gdone |= (gid == 9 && this.event(19));
		
		gdone |= (gid == 14 && this.event(47));
		
		if (gdone == 1) {
			this.animation.play("on");
		}
		if (this.s2 == 0) {
			this.s2 = 1;
			return;
		}
		
		
		this.s1 = 1;
		
		if (gdone == 1) { // gauntlet done
			// Allow replay after beating gmode
			if (this.event(47)) {
				this.dialogue("ui", "gauntlet_mode_info", 0);
				this.s1 = 100;
			} else {
				this.dialogue("ui", "gauntlet_mode_info", 2);
				this.s1 = 101;
			}
		} else {
			this.dialogue("ui", "gauntlet_mode", this.context_values[0]);
		}
	}
} else if (this.s1 == 101) {
	if (this.doff()) {
		this.s1 = 0;
	}
} else if (this.s1 == 100) {
	if (this.doff()) {
		this.dialogue("ui", "gauntlet_mode", this.context_values[0]);
		this.s1 = 1;
	}
} else if (this.s1 == 1) {
	if (this.d_last_yn() != -1) {
		if (this.d_last_yn() == 1) { 
			// reset flag for this area
			var gid = this.context_values[0];
			
			
			if (gid == 0) this.change_map("ROUGE_G1", 3, 29, true);
			if (gid == 1) this.change_map("SHORE_G1", 3, 61, true);
			if (gid == 2) this.change_map("CANYON_G1", 3, 67, true);
			if (gid == 3) this.change_map("HILL_G1", 3, 72, true);
			if (gid == 4) this.change_map("RIVER_G1", 3, 16, true);
			if (gid == 5) this.change_map("WOODS_G1", 3, 9, true);
			if (gid == 6) this.change_map("BASIN_G1", 15, 9, true);
			if (gid == 7) this.change_map("PASS_G0", 5, 43, true);
			if (gid == 8) this.change_map("CLIFF_G1", 8, 24, true);
			if (gid == 9) this.change_map("FALLS_G1", 9, 17, true);
			
			if (gid == 10) this.change_map("RADIO_DB", 43, 13, true); // depths
			
			if (gid == 11) this.change_map("EARTH_SILO_1B", 4, 15, true); // silos 
			if (gid == 12) this.change_map("AIR_SILO_1", 7, 19, true);
			if (gid == 13) this.change_map("SEA_SILO_1", 2, 19, true);
			
			if (gid == 14) this.change_map("RADIO_G1", 111, 100, true); // last
			
			this.s1 = 2;
		}  else {
			this.s1 = 0;
		}
	} 
}
