
if (!this.child_init) {
	this.child_init = true;
	this.width  -= 64;
	this.offset.x = 32;
	this.make_child("croissant");
	this.make_child("croissant");
	this.make_child("croissant");
	this.make_child("croissant");
	this.s1 = 0;
}
if (R.inventory.is_item_found(12) == true) {
	
	if (this.state_1 == 0) {
		this.alpha = 1;
		if (this.try_to_talk()) {
			this.dialogue("canyon", "food");
			this.state_1 = 1;
			this.t_1 = 0;
			return;
		}
		
		if (this.overlaps(R.player)) {
			this.t_1++;
			if (this.t_1 > 10) {
				this.t_1 = 0;
				R.player.add_dark(1);
			}
		}
	} else if (this.state_1 == 1) {
		if (!this.dialogue_is_on()) {
			
			if (this.parent_state.dialogue_box.last_yn == 1) {
				
			} else {
				this.state_1 = 0;
				return;
			}
			if (this.state_2 == 0) {
				
				this.t_1 ++;
				if (this.t_1 == 20) {
					this.t_1 = 0;
					this.s1++;
				}
				for (i in [0, 1, 2, 3]) {
					if (i != this.s1) continue;
					if (this.sprites.members[i].exists) continue;
					this.sprites.members[i].y = this.y + 80;
					this.sprites.members[i].alpha = 1;
					this.sprites.members[i].velocity.y = -100;
					this.sprites.members[i].acceleration.y = 350;
					this.sprites.members[i].exists = true;
					this.sprites.members[i].angularVelocity = -200 + 400 * this.random();
					this.play_sound("pew_hit.wav");
					//if (this.random() < 0.5) {
						//this.sprites.members[i].x = this.x + this.width - 32;
						//this.sprites.members[i].velocity.x = 60 + 90 * this.random();
					//} else {
						this.sprites.members[i].x = this.x + 16;
						this.sprites.members[i].velocity.x = -130 - 120 * this.random();
					//}
				}
				if (this.s1 == 3) {
					this.state_2 = 1;
					this.s1 = 0;
					this.t_1 = 0;
				}
				
				
				for (i in [0, 1, 2, 3]) {
					if (this.sprites.members[i].exists == true && this.sprites.members[i].overlaps(R.player)) {
						R.player.add_dark(1);
						this.play_sound("touch_weed.wav");
						this.sprites.members[i].exists = false;
					} 
				}
				
			} else if (this.state_2 == 1) {
				var b = false;
				for (i in [0, 1, 2, 3]) {
					this.sprites.members[i].alpha -= 0.01;
					if (this.sprites.members[i].exists == true && this.sprites.members[i].overlaps(R.player)) {
						R.player.add_dark(1);
						this.play_sound("touch_weed.wav");
						this.sprites.members[i].exists = false;
					} else if (this.sprites.members[i].alpha <= 0) {
						 this.sprites.members[i].exists = false;
					} 
					
					if (this.sprites.members[i].exists == true) {
						b = true;
					}
				}
				if (!b) {
					this.state_2 = 0;
					this.state_1 = 0;
				}
			}
		}
	}
	// Croissants??
} else {
	this.alpha = 0.3;
}