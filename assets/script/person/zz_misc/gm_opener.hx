if (!this.child_init) {
	this.child_init = true;
	this.only_visible_in_editor = true;
	
	if (this.context_values[0] == 100) {
		this._trace("setting events");
		this._trace("DEBUG: Gauntlet mode on");
		R.gauntlet_mode = true;
		R.warpModule.init();
		R.warpModule.set_checkbox_based_on_game_state();
	}
}

if (this.s1 == 0) {
	

	
		this.s1 = 1;
		var gid = this.context_values[0];

		//this.set_event(23);
		if (gid == 0 && this.event(23)) {
			this.broadcast_to_children("energize");
			R.achv.unlock(R.achv.gauntlet1);
		}
		
		//this.set_event(9);
		//this.set_event(12);
		//this.set_event(13);
		if (gid == 1 && this.event(9) && this.event(12) && this.event(13)) {
			this.broadcast_to_children("energize");
			R.achv.unlock(R.achv.gauntlet2);
		}
		
		//this.set_event(14);
		//this.set_event(15);
		//this.set_event(16);
		if (gid == 4 && this.event(15) && this.event(14) && this.event(16)) {
			this.broadcast_to_children("energize");
			R.achv.unlock(R.achv.gauntlet3);
		}
		
		//this.set_event(48);
		if (gid == 10 && this.event(48)) {
			this.broadcast_to_children("energize");
		}
		
		//R.inventory.set_item_found(1,23);
		//R.inventory.set_item_found(1,24);
		//R.inventory.set_item_found(1,25);
		if (gid == 11 && R.inventory.is_item_found(23) && R.inventory.is_item_found(24) && R.inventory.is_item_found(25)) {
			this.broadcast_to_children("energize");
		}
		
		//this.set_event(19);
		//this.set_event(18);
		//this.set_event(17);
		if (gid == 7 && this.event(17) && this.event(18) && this.event(19)) {
			this.broadcast_to_children("energize");
			R.achv.unlock(R.achv.gauntlet4);
		}
		
		//this.set_event(47);
		if (gid == 14 && this.event(47)) {
			this.broadcast_to_children("energize");
			R.achv.unlock(R.achv.gauntlet5);
			R.achv.speedrunCheck();
		}
	}
