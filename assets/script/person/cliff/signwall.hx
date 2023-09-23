// cliff
if (!this.child_init) {
	this.child_init = true;
	this.s1 = 1;
 	var c = this.context_values[0];
	//
	this.s2 = 1;
	var st = this.get_ss("cliff", "signs", 1);
	if ((st & (1 << c)) > 0) {
		this.s2 = 0;
	}
	this.make_child("cliff_signwall", false, "idle", true);
	
	this.set_Myblend(this.fg_sprites.members[0], 1);
	this.fg_sprites.members[0].alpha = 0;
	this.fg_sprites.members[0].scrollFactor.y = 0;
	this.alpha = 0;
	return;
}
var wall = this.fg_sprites.members[0];
wall.immovable = true;
wall.exists = true;
wall.x = this.x + this.width/2 - wall.width/2 ;
wall.y = 0;
wall.height = 3000;
if (this.s2 == 0) {
	if (this.try_to_talk(0, this, true)) {
		this.dialogue("cliff", "signs", this.context_values[0]);
	}
	this.fade_out(wall, 0.01, 0.95);
}
if (this.s2 == 1) {
	if (this.s1 == 1) {
		
		this.fade_in(wall, 0.05, 1.1);
		if (wall.alpha > 0.5) wall.alpha = 0.5;
		if (R.player.overlaps(wall)) {
			if (this.t_1 < 40) {
				this.t_1 ++;
			}
			if (R.player.velocity.x > 0) {
				R.player.velocity.x *= 0.8;
			}
			if (R.player.x + R.player.width > wall.x + 8) {
				R.player.x = wall.x + 8- R.player.width;
			}
		} else {
			this.t_1 = 0;
		}
		
		if (this.try_to_talk(0, this, true)) {
			this.dialogue("cliff", "signs", this.context_values[0]);
			this.set_ss("cliff", "signs", 1,this.get_ss("cliff", "signs", 1) | (1 << this.context_values[0]));
			this.s1 = 1;
			this.s2 = 0;
		}
	} else {
		if (this.doff()) {
			this.s1 = 0;
			this.s2 = 0;
		}
	}
}

