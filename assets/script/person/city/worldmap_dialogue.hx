
if (!this.child_init) {
	this.child_init = true;
	this.s1 = this.context_values[0];
	this.has_trigger = true;
	this.make_trigger(this.x, this.y, 64, 48);
	this.only_visible_in_editor = true;
	
	if (this.s1 == 4) {
		this.make_child("mapSmallPics", false, "mayor", true);
		this.fg_sprites.members[0].scrollFactor.set(0, 0);
		this.fg_sprites.members[0].alpha = 0;
		this.fg_sprites.members[0].exists = true;
		this.center_in_screen(this.fg_sprites.members[0]);
	}
}


if (this.s2 == 1) {
	if (this.doff()) {
		this.s2 = 0;
	}
}

if (R.worldmapplayer.overlaps(this.trigger)) {
	if (this.s1 == 0) {
		R.worldmapplayer.search_msp = "overworld,misc,0";
	} else if (this.s1 == 1) {
		R.worldmapplayer.search_msp = "overworld,misc,3"; // fish
	}else if (this.s1 == 2) {
		R.worldmapplayer.search_msp = "overworld,misc,4";//oak
		
	}else if (this.s1 == 3) {
		if (this.get_ss("overworld","misc",1) == 0) {
			this.dialogue("overworld", "misc", 5);
			this.set_ss("overworld", "misc", 1, 1);
			this.s2 = 1;
		}
		//R.worldmapplayer.search_msp = "overworld,misc,5";//woods
		
	}else if (this.s1 == 4) {
		R.worldmapplayer.search_msp = "overworld,misc,7";//scarecrw
		if (!this.doff()) {
			this.s1 = 104;
		}
		
	}else if (this.s1 == 5) {
		R.worldmapplayer.search_msp = "overworld,misc,10";//8 stones
		
	}else if (this.s1 == 6) {
		R.worldmapplayer.search_msp = "intro,map,3";//8 stones
		
	}else if (this.s1 == 7) {
		R.worldmapplayer.search_msp = "overworld,misc,11";//north
	}else if (this.s1 == 8) {
		R.worldmapplayer.search_msp = "overworld,misc,12";//south
	}else if (this.s1 == 9) {
		if (0 == R.event_state[50]) {
			R.worldmapplayer.search_msp = "overworld,misc,13";//south
		}
	}
}

if (this.s1 == 104) {
	if (this.doff()) {
		this.s1 = 105;
		R.worldmapplayer.pause_toggle(true);
	}
} else if (this.s1 == 105) {
	if (this.fade_in(this.fg_sprites.members[0])) {
		this.s1 = 106;
	}
} else if (this.s1 == 106) {
	if (R.input.jp_any()) {
		this.s1 = 107;
	}
} else if (this.s1 == 107) {
	if (this.fade_out(this.fg_sprites.members[0])) {
		this.s1 = 108;
	}
} else if (this.s1 == 108) {
	if (this.doff()) {
		R.worldmapplayer.pause_toggle(false);
		this.s1 = 4;
	}
}





