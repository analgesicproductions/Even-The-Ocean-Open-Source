// R, this, HF?
		// idle warn fire (all looped)

if (this.mode == this.MODE_IDLE) {
	this.t_idle += FlxG.elapsed;
	if (this.t_idle  > this.tm_idle) {
		this.t_idle = 0;
		this.mode = this.MODE_CHARGE;
		this.animation.play("warn");
	}
} else if (this.mode == this.MODE_CHARGE){
	this.t_charge += FlxG.elapsed;
	if (this.t_charge > this.tm_charge) {
		this.t_charge = 0;
		this.mode = this.MODE_SHOOT;
		this.animation.play("fire");
		
		i = 0;
		for (bullet in this.bullets.members) {
			if (bullet != null) {
				bullet.exists = true;
				bullet.x = this.x;
				bullet.y = this.y;
				bullet.velocity.y = this.max_bullet_vel * ((1.0 * (i + 1)) / this.num_bullets);
				bullet.velocity.x = 0;
				bullet.acceleration.y = 250;
			}
			i++;
		}
	}
} else if (this.mode == this.MODE_SHOOT) {
	for (bullet in this.bullets.members) {
		if (bullet != null) {
			if (bullet.overlaps(R.player)) {
				R.player.do_vert_push(bullet.velocity.y);
			}
		}
	}
	
	this.t_charge += FlxG.elapsed;
	if (this.t_charge > 3) {
		this.t_charge = 0;
		this.bullets.setAll("exists", false);
		this.mode = this.MODE_IDLE;
		this.animation.play("idle");
	}
}