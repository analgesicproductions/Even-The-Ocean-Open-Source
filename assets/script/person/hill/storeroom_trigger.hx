// Vera sprite, with Bay and Trent child. Trigger region starts.

if (!this.child_init) {
	//if (0 == this.get_ss("hill", "storeroom_outside", 1, 1)) {
		//this.set_ss("hill", "storeroom_outside", 1,0);
		//this.set_ss("hill", "bay_in_vera_room", 1,1);
		//this.set_ss("hill", "bay_outside", 1,1);
		//this.set_ss("hill", "trent_outside", 1, 1);
	//}
	this.t_1++;
	this.visible = false;
	if (this.t_1 == 60) {
		this.t_1 = 0;
		if (this.get_scene_state("hill", "storeroom_outside", 1) == 0 && this.get_ss("hill","bay_outside",1) == 1 && this.get_ss("hill","trent_outside",1) == 1) { // Got map. should be here now. If storeroom stuff seen, don't show up
			this.visible = true;
			// Only vera idles and talks about finding others
			this.s1 = -2;
			this.child_init = true;
		} else {
			this.visible = false;
			this.s1 = -1;
		}
	}
	return;
}
if (this.s1 == -2) {
	
	this.t_1++;
	if (this.t_1 == 60) {
		this.t_1 = 0;
		if (this.get_scene_state("hill", "bay_outside", 1) == 1 && this.get_scene_state("hill", "trent_outside", 1) == 1) {
			this.s1 = 0;
			this.has_trigger = true;
			this.make_trigger(this.x - 64, this.y, 32, 32);
			this.make_child("bay_outside",false,"idle_r"); // bay 
			this.make_child("trent_outside", false, "idle_l"); // trent
		
			this.set_vars(this.sprites.members[0], this.x - 32, this.y, 1, true);
			this.sprites.members[0].scale.x = -1;
			this.set_vars(this.sprites.members[1], this.x + 32, this.y, 1, true);
			
			
			this.make_child("mapSmallPics", false, "threeKeys", true);
			this.fg_sprites.members[0].scrollFactor.set(0, 0);
			this.fg_sprites.members[0].alpha = 0;
			this.fg_sprites.members[0].exists = true;
			this.center_in_screen(this.fg_sprites.members[0]);
			
			return;
		}
		
	}
	
	if (this.try_to_talk()) {
		this.dialogue("hill", "vera_outside_storehouse", 0);
	}
} if (this.s1 == -1) {
	
} else if (this.s1 == 0) {
	if (this.s2 == 0) {
		if (R.player.overlaps(this.trigger)) {
			this.s2 = 1;
		}
	} else if (this.s2 == 1){ 
		if (this.player_freeze_help()) {
			this.s2 = 2;
			this.dialogue("hill", "storeroom_outside", 0,false);
			R.player.pause_toggle(true);
		}
	} else if (this.s2 == 2) {
		if (!this.dialogue_is_on()) {
			this.broadcast_to_children("energize_tick_l");
			this.s2 = 10;
			this.t_1 = 0;
		}
	}  else if (this.s2 == 3) {
		this.t_1 ++;
		if (this.t_1 > 60) {
			this.start_invisible_player_cutscene("HILL_4", 2536, 507,true);
			this.set_scene_state("hill", "storeroom_outside", 1, 1);
			this.s2 = 4;
		}
	} else if (this.s2 == 10) {
		if (this.fade_in(this.fg_sprites.members[0])) {
			this.s2 = 11;
			this.t_1 = 0;
		}
	}else if (this.s2 == 11) {
		this.t_1 ++;
		if (this.t_1 > 60) {
			if (this.fade_out(this.fg_sprites.members[0])) {
				this.s2 = 12;
				this.t_1 = 0;
				this.fg_sprites.members[0].animation.play("oneKey");
			}
		}
		
	}else if (this.s2 == 12) {
		if (this.fade_in(this.fg_sprites.members[0])) {
			this.s2 = 13;
			this.t_1 = 0;
		}
	}else if (this.s2 == 13) {
		this.t_1 ++;
		if (this.t_1 > 60) {
			this.dialogue("hill", "storeroom_outside", 12,false);
			this.s2 = 14;
			this.t_1 = 0;
		}
	}else if (this.s2 == 14) {
		if (this.doff()) {
			if (this.fade_out(this.fg_sprites.members[0])) {
				this.s2 = 3;
			}
		}
	}else if (this.s2 == 15) {
		
	}
}