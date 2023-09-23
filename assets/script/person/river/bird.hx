//riverbird
if (!this.child_init) {
	this.child_init = true;
	
	this.s1 = 0;
	
	this.make_child("ronald_bird", false, "white_riveridle");
	
	this.only_visible_in_editor = true;
	
	
	// time to fly in
	this.t_1 = 1 * 60 + this.rand_int(0, 5 * 60);
	//this.t_1 = 1 * 60 + this.rand_int(0, 1 * 60);
	
}

var bird = this.sprites.members[0];


if (this.s1 == 0) {
	bird.alpha = 0;
	bird.exists = bird.visible = true;
	bird.x = this.ix;
	bird.y = this.iy - 80;
	if (this.random() > 0.5) {
		bird.scale.x = -1;
	} else {
		bird.scale.x = 1;
	}
	this.s1 = 1;
} else if (this.s1 == 1) {
	this.t_1--;
	if (this.t_1 <= 0) {
		if (this.context_values[0] == 0) {
			bird.animation.play("white_fly");
		} else {
			bird.animation.play("rag_fly");
		}
		bird.velocity.y = 106.7;
		bird.acceleration.y = -71;
		this.s1 = 2;
	}
}else if (this.s1 == 2) {
	bird.alpha += 0.02;
	if (bird.y >= this.iy) {
		if (this.context_values[0] == 0) {
			bird.animation.play("white_riveridle");
		} else {
			bird.animation.play("rag_riveridle");
		}
		bird.y = this.iy;
		bird.velocity.y = 0;
		bird.acceleration.y = 0;
		// time to wait
		this.s1 = 3;
		this.t_1 = 20 * 60 + this.rand_int(0, 10 * 60);
		//this.t_1 = 1 * 60 + this.rand_int(0, 2* 60);
	}
	
}else if (this.s1 == 3) {
	this.t_1 --;
	if (R.player.overlaps(bird) && R.player.velocity.x != 0) {
		this.t_1 = 0;
	}
	if (this.t_1 <= 0) {
		if (this.context_values[0] == 0) {
			bird.animation.play("white_fly");
		} else {
			bird.animation.play("rag_fly");
		}
		bird.acceleration.y = -80;
		bird.velocity.x = -100 + 200 * this.random();
		if (bird.velocity.x <= 0) {
			bird.scale.x = 1;
		} else {
			bird.scale.x = -1;
		}
		this.s1 = 4;
	}
	
}else if (this.s1 == 4) {
	bird.alpha -= 0.006;
	if (bird.alpha <= 0) {
		bird.velocity.set(0, 0);
		bird.acceleration.y = 0;
		this.s1 = 0;
		this.t_1 = 5 * 60 + this.rand_int(0, 5 * 60);
		//this.t_1 = 1 * 60 + this.rand_int(0, 2 * 60);
	}
}