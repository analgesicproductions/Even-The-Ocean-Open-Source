//{ i2_mayor_init

if (!this.child_init) {
	this.child_init = true;
	this.only_visible_in_editor = true;
	this.s1 = 0;
	//this._trace("DEBUG 5b_mayor");
	//this.set_ss("i2", "cart_init", 1, 1);
	//this.set_ss("i2", "mayor_init", 1, 0);
	if (this.get_ss("i2", "cart_init", 1) == 1 && this.get_ss("i2", "mayor_init", 1) == 0) {
		this.make_child("biggs", false, "idle_l");
		this.set_vars(this.sprites.members[0], this.x + 16, this.y, 1);
	} else {
		this.SCRIPT_OFF = true;
		return;
	}
	
	R.attempted_door = "";
	R.song_helper.permanent_song_name = "wf_city_attack";
	this.play_music("wf_city_attack");
	
		R.player.x = R.player.last.x = this.x-16;
		R.player.y = R.player.last.y = this.y + 12;
		R.player.velocity.x = 0;
		R.player.velocity.y = 0;
		
	// first dialgoue messed up
	
}
//this._trace(R.attempted_door);
//this._trace(this.s1);
var biggs = this.sprites.members[0];
if (this.s1 == 0) {
	this.t_1++;
	if (this.t_1 > 3) {
		
	R.player.facing = 0x0010;
	R.player.animation.play("irn");
		this.t_1 = 0;
		this.dialogue("i2", "mayor_init", 0);
		this.s1 = 1;
		R.ignore_door = true;
		R.player.touching = 0x1000;
		
	}	
} else if (this.s1 == 1 && this.doff()) {
	if (this.try_to_talk(0,biggs, false)) {
		this.s1 = 2;
		this.dialogue("i2", "mayor_init", 7);
	}
	if (R.attempted_door != null && R.attempted_door.length > 1) {
		if (R.attempted_door != "RADIO_LOBBY") {
			this.s1 = 2;
			this.dialogue("i2", "mayor_init", 8);
		} else {
			this.set_ss("i2", "mayor_init", 1, 1);
			this.change_map("RADIO_DB", 44, 13, true);
			this.s1 = 3;
			R.song_helper.permanent_song_name = "";
			this.play_music("null");
		}
	}
} else if (this.s1 == 2 && this.doff()) {
	this.t_1 ++;
	if (this.t_1 > 15) {
		this.s1 = 1;
		this.t_1 = 0;
			R.attempted_door = "";
	}
}