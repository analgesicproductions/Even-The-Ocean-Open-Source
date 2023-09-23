if (this.s2 == 0){
	this.only_visible_in_editor = true;
	this.immovable = true;
	var i = this.context_values[0];
	if (i == 0) this.debug_name.text = "shore blocker";
	if (i == 1) this.debug_name.text = "canyon blocker";
	if (i == 2) this.debug_name.text = "hill blocker";
	if (i == 3) this.debug_name.text = "river blocker";
	if (i == 4) this.debug_name.text = "woods blocker";
	if (i == 5) this.debug_name.text = "basin blocker";
	if (i == -1) this.debug_name.text = "rouge blocker";
	
	
	if (R.inventory.is_item_found(30)) {
		this._trace("gaunetlet blocker off bc have postgame transmitter 30");
		this.SCRIPT_OFF = true;
		return;
	}
	
	
	this.s2 = 1;
	
	//R.set_flag(EF.shore_done, false);
	//R.set_flag(EF.canyon_done, true);
	//R.set_flag(13, true);
	if (i == 0 && !this.event(9)) {
		this.s1 = 2;
	} else if (i == 1 && !this.event(12)) {
		this.s1 = 2;
	}else if (i == 2 && !this.event(13)) {
		this.s1 = 2;
	}else if (i == 3 && !this.event(15)) {
		this.s1 = 2;
	}else if (i == 4 && !this.event(14)) {
		this.s1 = 2;
	}else if (i == 5 && !this.event(16)) {
		this.s1 = 2;
	} else if (i == -1 && !this.event(23)) {
		this.s1 = 2;
	}
}

if (this.s1 == 0) {
	if (this.player_separate(this)) {
		this.state_1 = 1;
	} else {
		this.state_1 = 0;
	}
	if (this.state_1 == 1 && R.player.wasTouching == 0x1000) {
		if (R.player.velocity.x > 0 && R.player.facing == 0x0010) {
			R.player.last.x -= 1;
		} else if (R.player.velocity.x < 0 && R.player.facing == 0x0001) {
			R.player.last.x += 1;
		}
		R.player.x = R.player.last.x;
		this.player_play_idle_and_zero_xvel();
		var j = this.context_values[0];
		this.dialogue("test", "blocker", j);
		this.s1 = 1;
	}
} else if (this.s1 == 1) {
	if (this.dialogue_is_on() == false) {
		this.s1 = 0;
		this.state_1 = 0;
	}
}