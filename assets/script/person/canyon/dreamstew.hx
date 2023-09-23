if (!this.child_init) {
	this.child_init = true;
	this.make_child("moon_stew",true);
	this.make_child("moon_stew",true);
	this.make_child("moon_stew", true);
	this.make_child("moon_stew", true);
	for (i in [0, 1, 2, 3]) {
		//this.bg_sprites.members[i].alpha = 0;
		this.fade_out(this.bg_sprites.members[i], 1, 0, 0, 0);
		this.bg_sprites.members[i].animation.play("smoke");
		this.bg_sprites.members[i].exists = true;
	}
	this.t_1 = 61;
}


this.t_1 ++;
if (this.t_1 > 25) {
	this.t_1 = 0;
	for (i in [0, 1, 2, 3]) {
		var s = this.bg_sprites.members[i];
		if (s.alpha == 0) {
		s.x  = this.x;
		s.y = this.y;
			//s.alpha = 1;
			this.fade_in(s, 1, 1);
			s.angle = this.random() * 360;
			s.velocity.x = -5 + 10 * this.random();
			s.velocity.y = -12 - 4 * this.random();
			break;
			
		} 
	}
}


	for (i in [0, 1, 2, 3]) {
		var s = this.bg_sprites.members[i];
		if (s.alpha > 0) {
			if (s.y < this.y-5) {
				this.fade_out(s, 0.001, 0.95);
			}
		} else {
			this.fade_out(s, 1, 0, 0, 0);
			s.velocity.y = 0;
			s.velocity.x = 0;
		}
	}

