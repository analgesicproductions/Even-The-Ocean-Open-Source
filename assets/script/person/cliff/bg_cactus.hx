if (!this.child_init) {
	this.child_init = true;
	
	
	//this._trace("cactus debug");
	//R.story_mode = true;
	//R.inventory.set_item_found(0,27); // scent
	
	this.make_child("cliff_spore", false, "idle");
	this.make_child("cliff_cactus", false, "idle");
	
	this.s1 = 0;
	this.set_vars(this.sprites.members[0], this.x, this.y, 1);
	this.set_vars(this.sprites.members[1], this.x, this.y, 1);
	
	this.only_visible_in_editor = true;
	this.s2 = this.context_values[0];
	if (this.event(18)) {
		this.s1 = -1;
		
	}
}

var spore = this.sprites.members[0];
var cactus = this.sprites.members[1];

this.t_2 += 3;
if (this.t_2 > 359) {
	this.t_2 = 0;
}

if (this.s1 == -1) {
	cactus.x = this.ix;
	cactus.y = this.iy;
	spore.alpha = 0;
}


spore.offset.y = 4 * this.get_sin(this.t_2);

if (this.s1 == 0) {
	cactus.x = this.ix;
	cactus.y = this.iy;
	this.s1 = 1;
	spore.alpha = 0;
	if (this.s2 == 1) {
		spore.x = cactus.x + 400;
	} else {
		spore.x = cactus.x - 400;
	}
	spore.y = cactus.y - spore.height;
	this.t_1 = 0;
} else if (this.s1 == 1) {
	
	if (this.s2 == 1) {
		this.t_1++;
		if (this.t_1 > 300) {
			
		} else {
			return;
		}
	}
	if (this.s2 == 1) {
		spore.velocity.x = -80;
	} else {
		spore.velocity.x = 80;
	}
	spore.alpha += 0.02;
	if (this.s2 == 1 && spore.x < cactus.x) {
		spore.x = cactus.x;
		spore.velocity.x = 0;
	} else if (this.s2 == 1 && spore.x == cactus.x) {
		spore.velocity.x = 0;
		if (spore.offset.y == 0) {
			this.s1 = 2;
			this.t_1 = 0;
			spore.animation.play("close");
		}
	}
	
	if (this.s2 == 0 && spore.x > cactus.x) {
		spore.x = cactus.x;
		spore.velocity.x = 0;
	} else if (this.s2 == 0 && spore.x == cactus.x) {
		spore.velocity.x = 0;
		if (spore.offset.y == 0) {
			this.s1 = 2;
			this.t_1 = 0;
			spore.animation.play("close");
		}
	}
} else if (this.s1 == 2) {
	
	cactus.offset.y = 16 + 4 * this.get_sin(this.t_2);
	this.t_1 ++;
	if (this.t_1 > 120) {
		this.t_1 = 0;
		if (this.s2 == 1) {
			spore.velocity.y = cactus.velocity.y = -40;
			spore.velocity.x = cactus.velocity.x = 80;
		} else {
			spore.velocity.y = cactus.velocity.y = -40;
			spore.velocity.x = cactus.velocity.x = -80;
		}
		this.s1 = 3;
	}
} else if (this.s1 == 3) {
	
	cactus.alpha -= 0.02;
	spore.alpha -= 0.02;
	cactus.offset.y = 16 + 4 * this.get_sin(this.t_2);
	if (cactus.y < 280) {
		spore.alpha = 0;
		spore.velocity.y = cactus.velocity.y = 0;
		spore.velocity.x = cactus.velocity.x = 0;
		cactus.alpha = 1;
		cactus.animation.play("grow");
		cactus.x = this.ix;
		cactus.y = this.iy;
		cactus.offset.y = 16;
		spore.animation.play("idle");
		this.s1 = 4;
	}
	
} else if (this.s1 == 4) {
	this.t_1 ++;
	if (this.t_1 > 120) {
		this.t_1 = 0;
		this.s1 = 0;
	}
} else if (this.s1 == 5) {
	
}





