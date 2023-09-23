if (!this.child_init) {
	this.child_init = true;
	if (R.dialogue_manager.is_chinese()) {
		this.make_child("oldocean_map_zh_Hans", false, "", true);
	} else if (R.dialogue_manager.get_langtype() == 6)  {
		this.make_child("oldocean_map_es" , false, "", true);
	} else if (R.dialogue_manager.get_langtype() == 5)  {
		this.make_child("oldocean_map_ru" , false, "", true);
	} else if (R.dialogue_manager.get_langtype() == 4) {
		this.make_child("oldocean_map_de" , false, "", true);
	} else {
		this.make_child("oldocean_map", false, "", true);
	}
	this.scale.set(2, 2);
	this.fg_sprites.members[0].scrollFactor.set(0, 0);
	this.fg_sprites.members[0].alpha = 0;
	this.fg_sprites.members[0].exists = true;
	this.center_in_screen(this.fg_sprites.members[0]);
	this.s1 = 4;
	this.height = 48;
}

if (this.s1 == 4) {
	if (this.try_to_talk()) {
		this.dialogue("overworld", "misc", 16);
		this.s1 = 103;
	}
}

if (this.s1 == 103) {
	if (0 == this.d_last_yn()) {
		this.s1 = 104;
	} else if (3 == this.d_last_yn()) {
		this.s1 = 4;
	} else {
		if (this.doff()) {
			this.dialogue("overworld", "misc", 16);
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
		this.dialogue("overworld", "misc", 16);
		this.s1 = 103;
	}
}
