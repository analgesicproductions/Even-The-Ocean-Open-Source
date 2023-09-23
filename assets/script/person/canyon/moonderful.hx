if (!this.child_init) {
	this.child_init = true;
	this.init_loopsound("fire.wav", 7575);
	if (0 == this.get_ss("canyon", "moonderful_first", 2)) {
		this.s3 = 0;
		this.has_trigger = true;
		this.make_trigger(this.x, this.y - 48,64,64);
	} else {
		this.s3 = 1;
	}
}


if (this.s3 == 0) {
	if (R.player.overlaps(this.trigger)) {
		this.s3 = 2;
	}
} else if (this.s3 == 2) {
	if (this.player_freeze_help()) {
		this.scale.x = -1;
		this.dialogue("canyon", "moonderful_first", 0);
		this.s3 = 1;
	}
}
if (this.s3 == 1 && this.doff()) {
	if (this.try_to_talk()) {
		this.scale.x = 1;
		this.dialogue("canyon", "moonderful_first", 0);
	}
}


if (this.s2 == 0) {
	this.width += 128;
	this.height += 64;
	this.x -= 64;
	this.y -= 32;
	if (R.player.overlaps(this)) {
		this.s2 = 1;
		this.begin_loopsound();
	}
	this.width -= 128;
	this.height -= 64;
	this.x += 64;
	this.y += 32;
} else if (this.s2 == 1) {
	this.width += 128;
	this.height += 64;
	this.x -= 64;
	this.y -= 32;
	if (!R.player.overlaps(this)) {
		this.s2 = 0;
		this.stop_loopsound();
	}
	this.width -= 128;
	this.height -= 64;
	this.x += 64;
	this.y += 32;
	
}

//if (this.s1 == 1) {
	//if (this.animation.finished == true) {
		//this.s1 = 0;
		//this.play_anim("idle_l");
	//}
//} else {
	//this.t_1 ++;
	//if (this.t_1 > 180) {
		//this.t_1 = 0;
		//if (this.random() < 0.33) {
			//this.play_anim("stir2");
		//} else if (this.random() < 0.5) {
			//this.play_anim("stir3");
		//} else {
			//this.play_anim("stir2");
		//}
		//this.s1 = 1;
	//}
//}