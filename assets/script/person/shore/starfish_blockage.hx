	if (this.state_1 == 0) {
		this.width = 12;
		this.offset.x = 2;
		this.state_1 = 1;
		if (this.context_values[0] == 0) {
			if (R.event_state[11] & 0x100 != 0) {
				this.state_1 = 3;
			}
		} else if (this.context_values[0] == 1) {
			if (R.event_state[11] & 0x10 != 0) {
				this.state_1 = 3;
			}
		} else if (this.context_values[0] == 2) {
			if (R.event_state[11] & 0x1 != 0) {
				this.state_1 = 3;
			}
		}
	} else if (this.state_1 == 1) {
		this.immovable = true;
		this.player_separate(this);
		if (this.try_to_talk(3,this,true)) {
			if (R.inventory.is_item_found(10)) { // cure if have the medicine
				this.state_1 = 2;
				if (this.context_values[0] == 0) {
					R.set_flag_bitwise(11, 0x100);
					this.dialogue("shore", "starfish_arms", 0);
				} else if (this.context_values[0] == 1) {
					R.set_flag_bitwise(11, 0x010);
					this.dialogue("shore", "starfish_arms", 1);
				} else if (this.context_values[0] == 2) {
					R.set_flag_bitwise(11, 0x001);
					this.dialogue("shore", "starfish_arms", 2);
				}
			} else {
				this.dialogue("shore", "starfish_arms", 3);
			}
		}
	} else if (this.state_1 == 2) { // fade away after being cured
		this.alpha -= 0.03;
		if (this.alpha == 0) {
			this.state_1 = 2;
		}
	} else if (this.state_1 == 3) {
		this.alpha = 0;
	}
