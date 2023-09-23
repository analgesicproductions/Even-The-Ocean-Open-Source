//{ falls_rotate
//script s "person/falls/rotate.hx"
//}
if (!this.child_init) {
	this.child_init = true;
	this.only_visible_in_editor = true;
	this.s1 = 0;
	this.s2 = 0;
	this.make_child("falls_rotate_bg",true,"boat");
	this.make_child("falls_rotate_boat", true, "vis");
	
	this.set_vars(this.bg_sprites.members[0], -64, -80-64, 1);
	this.set_vars(this.bg_sprites.members[1], 0, 0, 1);
	this.bg_sprites.members[1].alpha = 0;
}

var boat = this.bg_sprites.members[1];
var bg = this.bg_sprites.members[0];
if (this.s1 == 0) {
	this.t_1++;
	if (this.t_1 > 3) {
		
		this.energy_bar_move_set(false, true); // Hide the energy bar
		R.player.energy_bar.dont_move_cutscene_bars = true;
		this.t_1 = 0;
		R.player.enter_cutscene();
		R.player.pause_toggle(false);
		R.player.animation.play("irn");
		R.player.y = 256 - 32 - 24;
		R.player.x = 175;
		this.s1 = 1;
	}
} else if (this.s1 == 1) {
	this.t_1++;
	if (this.t_1 > 60) {
		this.t_1 = 0;
		R.player.velocity.x = 20;
		R.player.animation.play("wrr");
		this.s1 = 2;
		boat.x  = 216;
		boat.y = R.player.y + 5  -38;
	}
} else if (this.s1 == 2) {
	this.s2 ++;
	if (this.s2 % 2 == 0) {
		this.my_set_angle(bg, bg.angle+1);
		if (bg.angle >= 90) {
			this.my_set_angle(bg, 90);
			this.bg_sprites.members[1].alpha = 1;
			this.bg_sprites.members[0].animation.play("no_boat");
		}
	}
	if (bg.angle >= 90) {
		this.s1 = 3;
		this.s1 = 3;
	}
} else if (this.s1 == 3 ) {
	if (R.player.x > boat.x + 18) {
		R.player.velocity.x = 0;
		R.player.animation.play("irn");
		this.s1 = 4;
	}
} else if (this.s1 == 4) {
	this.t_1 ++;
	if (this.t_1 > 30) {
		this.t_1 = 0;
		R.player.velocity.x = 50;
		boat.velocity.x = 50;
		if (boat.x > 460) {
			this.s1 = 5;
			if (R.story_mode) {
				this.change_map("FALLS_B", 40, 48, true);
			} else {
				this.change_map("FALLS_G1", 12, 0, true);
			}
			this.energy_bar_move_set(true); // show the energy bar
		}
	}
}