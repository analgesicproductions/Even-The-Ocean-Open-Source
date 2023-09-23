//{ junk_enter
if (!this.child_init) { 
	this.child_init = true;
	this.make_child("city_trunks",false,"trunks_idle_l"); // Flute 
	this.make_child("city_dahlia",false,"dahlia_idle_l"); // guitar 
	this.make_child("city_pollen",false,"pollen_idle_l"); // 
	this.has_trigger = true;
	this.make_trigger(this.x - 32, this.y - 100, 20, 132);
	this.s3 = 0;
	if (1 == this.get_ss("city", "wf_j", 1)) {
		this.s3 = 1;
	}
	this.s1 = 0;
	this.s2 = 0;
}	

var tr = this.sprites.members[0];
var da = this.sprites.members[1];
var po = this.sprites.members[2];


if (this.s2 == 0) {
	this.s2 = 1;
	this.set_vars(tr, this.x + 48, this.y,1);
	this.set_vars(da, this.x + 80, this.y,1);
	this.set_vars(po, this.x + 120, this.y, 1);
	this.width = 16;
	this.offset.x = 2;
	tr.width = 8;
	tr.offset.x = 2;
	da.width = 8;
	da.offset.x = 2;
	tr.animation.play("trunks_idle_l");
}
if (this.s3 == 0) {
	
if (this.s1 == 0) {
	if (R.player.overlaps(this.trigger)) {
		this.s1 = 10;
	}
} else if (this.s1 == 10) {
	if (this.player_freeze_help()) {
		this.set_ss("city", "wf_j", 1, 1);
		this.dialogue("city", "wf_j", 0);
		this.s1 = 1;
	}
} else if (this.s1 == 1) {
	if (this.doff()) {
		this.s3 = 1;
		this.s1 = 0;
	}
}

} else if (this.s3 == 1) {
	if (this.s1 == 10) {
		//this._trace(10);
		if (this.try_to_talk(0,this)) {
			this.s1 = 2;
			this.dialogue("city", "wf_j", 8);
			return;
		}
		if (!this.try_to_talk_do_generic_walk && !R.player.overlaps(this)) {
			this.s1 = 0;
		}
	}
	if (this.s1 == 0) {
		//this._trace(0);
		if (R.player.overlaps(this)) {
			this.s1 = 10;
			this.set_try_to_talk_lock_sprite(null);
			this.try_to_talk_do_generic_walk  = false;
			return;
		}
		if (this.try_to_talk(0,tr)) {
			this.s1 = 1;
			this.dialogue("city", "wf_j", 9);
		}
		if (this.try_to_talk(0,da)) {
			this.s1 = 1;
			this.dialogue("city", "wf_j", 10);
		}
		if (this.try_to_talk(0,po)) {
			this.s1 = 1;
			this.dialogue("city", "wf_j", 11);
		}
	} else if (this.s1 == 1 && this.doff()) {
		this.s1 = 0;
	} else if (this.s1 == 2 && this.doff()) {
		if (this.d_last_yn() == 0) {
			R.player.pause_toggle(true); 
			this.change_map("WF_JS", 3, 38, true);
			this.s1 = 3;
		} else if (this.d_last_yn() == 1) {
			R.player.pause_toggle(true); 
			this.change_map("WF_JC", 2, 24, true);
			this.s1 = 3;
		} else if (this.d_last_yn() == 2) {
			R.player.pause_toggle(true); 
			this.change_map("WF_JH", 3, 20, true);
			this.s1 = 3;
		} else {
			this.s1 = 0;
		}
	}
}
