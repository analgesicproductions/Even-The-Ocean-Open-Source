if (this.state_1 == 0) {
	this.immovable = true;
	this.state_1 = 1;
	this.animation.play("idle");
} else if (this.state_1 == 1) {
}

this.t_1 ++;
if (this.t_1 >= 720) {
	this.t_1 = 0;
}

if (R.editor.editor_active) {
	this.x = this.ix;
	this.y = this.iy;
	this.t_1 = 0;
	this.t_2 = 0;
	this.velocity.y = 0;
	this.acceleration.y = 0;
}

//if (R.player.touching == 0x1000) {
	//R.player.velocity.y = this.velocity.y + 0.0167*this.acceleration.y;
//}	
//
//if (this.t_2 == 0) {
	//this.acceleration.y = 50;
	//if (this.velocity.y > 50) {
		//this.t_2 = 1;
	//}
//} else {
	//this.acceleration.y = -50;
	//if (this.velocity.y < -50) {
		//this.t_2 = 0;
	//}
//}


//this.width -= 4;
//this.y -= 2;
//this.x += 2;
//
//if (R.player.overlaps(this)) {
	//R.player.touching = 0x1000;
	//this.x -= 2;
	////R.player.extra_x = (this.ix + 	16 * 6 * this.get_sin(this.t_1 / 2)) - this.x;
	//this.x += 2;
//}
//this.width += 4;
//this.y += 2;
//this.x -= 2;

this.width = 64;
this.offset.x = 32;
this.offset.y = 35;

this.height = 36 - 12;


	this.x = this.ix + 	18 * 6 * this.get_sin(this.t_1 / 2);
	
if (this.t_1 == 200) {
	this.animation.play("turn");
}
if (this.t_1 == 208) {
	this.animation.play("movingback");
}
if (this.t_1 == 552) {
	this.animation.play("turn");
}
if (this.t_1 == 560) {
	this.animation.play("moving");
}

if (R.inventory.is_item_found(12)) {
	this.alpha = 1;
	this.wall_climbable = true;
} else {
	//this.alpha = 1;
	//this.wall_climbable = true;
	this.alpha = 0.5;
	this.wall_climbable = false;
}