

//{ orb_gate

if (!this.child_init) {
	this.child_init = true;
	
	/* Initialize state variables */
	this.s1 = 0;
	this.s2 = 0;
	
	
	this.immovable = true;
	
	this.s2 = this.context_values[0];
	
	
	if (this.s2 == 0) {
	//for (i in [31, 32, 33, 34, 35, 36, 37, 38]) {
		//R.inventory.set_item_found(0, i,false);
	//}
		if (this.get_ss("p", "orb_gate", 1) == 1) {
			this.y -= 128;
		}
	} else if (this.s2 == 1) {
		//for (i in [39,40,41]) {
			//R.inventory.set_item_found(0, i,false);
		//}
		//for (i in [39,40,41]) {
			//R.inventory.set_item_found(0, i);
		//}
		this.animation.play("1");
		if (this.get_ss("p", "jewel_gate", 1) == 1) {
			this.y += 128;
		}
		
	} else if (this.s2 == 2) {
		
		this.animation.play("2");
		this.height = 64;
		this.width = 32;
		if (this.get_ss("p", "rock_gate", 1) == 1) {
			this.y += this.height;
		}
		//for (i in [42,43]) {
			//R.inventory.set_item_found(0, i);
		//}
		//for (i in [42,43]) {
			//R.inventory.set_item_found(0, i,false);
		//}
	}
	
}



// Do stuff
this.player_separate(this);

if (this.s2 == 0) {
	if (this.s1 == 0) {
		if (this.try_to_talk(8, this, true)) {
			for (i in [31, 32, 33, 34, 35, 36, 37, 38]) {
				if (R.inventory.is_item_found(i) == false) {
					this.dialogue("p", "orb_gate", 0);
					this.s1 = 1;
					return;
				}
			}
			this.s1 = 2;
			this.dialogue("p", "orb_gate", 1);
			this.set_ss("p", "orb_gate", 1, 1);
		}
	} else if (this.s1 == 1 && this.doff()) {
		this.s1 = 0;
	} else if (this.s1 == 2 && this.doff()) {
		this.velocity.y = -50;
		if (this.y < this.iy - 128) {
			this.velocity.y = 0;
			this.s1 = 0;
		}
	}
} else if (this.s2 == 1) {
	if (this.s1 == 0) {
		if (this.try_to_talk(8, this, true)) {
			for (i in [39,40,41]) {
				if (R.inventory.is_item_found(i) == false) {
					this.dialogue("p", "jewel_gate", 0);
					this.s1 = 1;
					return;
				}
			}
			this.s1 = 2;
			this.dialogue("p", "jewel_gate", 1);
			this.set_ss("p", "jewel_gate", 1, 1);
		}
	} else if (this.s1 == 1 && this.doff()) {
		this.s1 = 0;
	} else if (this.s1 == 2 && this.doff()) {
		this.velocity.y = 50;
		if (this.y > this.iy + this.height) {
			this.velocity.y = 0;
			this.s1 = 0;
		}
	}
}else if (this.s2 == 2) {
	if (this.s1 == 0) {
		if (this.try_to_talk(8, this, true)) {
			for (i in [42,43]) {
				if (R.inventory.is_item_found(i) == false) {
					this.dialogue("p", "rock_gate", 0);
					this.s1 = 1;
					return;
				}
			}
			this.s1 = 2;
			this.dialogue("p", "rock_gate", 1);
			this.set_ss("p", "rock_gate", 1, 1);
		}
	} else if (this.s1 == 1 && this.doff()) {
		this.s1 = 0;
	} else if (this.s1 == 2 && this.doff()) {
		this.velocity.y = 50;
		if (this.y > this.iy + this.height) {
			this.velocity.y = 0;
			this.s1 = 0;
		}
	}
}