//{ river_jr_gatekeeper
if (!this.child_init) {
	this.child_init = true;
	this.only_visible_in_editor = true;
	this.s1 = 0;
	this.s2 = 0;
	//this._trace("DEBUG river gatekeeper.hx");
	//this.set_ss("river", "post_office", 1, 1);
	//this.set_ss("river", "jr_2", 1, 0);
	
	this.make_child("river_jr_sprite",false,"idle");
	this.make_child("river_gatekeeper_sprite",false,"idle");
	if (this.get_ss("river", "jr_2", 1) == 1) {
		this.s1 = 200; // after, gatekeeper idling?
		this.s2 = 1;
	} else if (this.get_ss("river", "post_office", 1) == 1) {
		this.s1 = 100; // gatekeerp scene start
	}
	R.player.enter_main_state();
	this.s3 = -1;
}

var jr = this.sprites.members[0];
var dad = this.sprites.members[1];

if (this.s3 == -1) {
	this.set_vars(jr, this.x-16, this.y, 1);
	this.set_vars(dad, 89*16, 34*16, 1);
	this.s3 = 0;
	dad.visible = true;
	dad.scale.x = 1;
	dad.animation.play("nap");
	
	
	if (this.s1 == 200) {
		dad.visible = true;
		dad.x = this.children[0].x - 2 - dad.width;
		dad.y = jr.y;
		dad.animation.play("nap");
		//dad.animation.play("idle_r");
	}
}

if (this.s1 == 0) {
	if (this.try_to_talk(0, jr, false)) {
		this.s1 = 1;
		if (this.get_ss("river", "post_office", 1) == 1) {
			 
			this.s1 = 101;
			this.set_ss("river", "jr_2", 1, 1);
			this.dialogue("river", "jr_2", 0,false);
		} else {
			this.dialogue("river", "jr_1", 0);
			this.set_ss("river", "jr_1", 1, 1);
		}
	}
	if (this.try_to_talk(0, dad, false)) {
		this.dialogue("river", "keepers_after", 3);
	}
} else if (this.s1 == 1 && this.doff()) {
	this.s1 = 0;
}

if (this.s1 == 100) {
	if (this.try_to_talk(0, jr, false)) {
		this.s1 = 101;
		this.set_ss("river", "jr_2", 1, 1);
		this.dialogue("river", "jr_2", 0,false);
	}
	if (this.try_to_talk(0, dad, false)) {
		this.dialogue("river", "keepers_after", 3);
	}
} else if (this.s1 == 101 && this.doff()) {
	dad.scale.x = -1;
	dad.x = jr.x - 112;
	dad.y = jr.y - 32;
	dad.alpha = 0;
	dad.animation.play("walk_r");
	dad.visible = true;
	this.s1 = 102;
} else if (this.s1 == 102) {
	dad.velocity.x = 80;
	dad.alpha = dad.alpha + 0.04;
	
	dad.velocity.y = 50;
	this.separate(dad);
	dad._minslopebump = 0;
	if (dad.x > jr.x - 48) {
		dad.velocity.x = 0;
		dad.velocity.y = 0;
		dad.animation.play("idle_r");
		R.player.animation.play("iln");
		this.dialogue("river", "jr_3", 0);
		this.s1 = 103;
	}
} else if (this.s1 == 103 && this.doff()) {
	R.player.enter_cutscene();
	dad.velocity.x = 80;
	dad.velocity.y = 50;
	this.separate(dad);
	dad._minslopebump = 0;
	dad.animation.play("walk_r");
	if (dad.x > this.children[0].x - 2 - dad.width) {
		dad.velocity.x = 0;
	dad.velocity.y = 0;
		dad.animation.play("idle_r");
		this.s1 = 104;
	}
	
} else if (this.s1 == 104) {
	this.t_1++;
	if (this.t_1 > 60) {
		this.broadcast_to_children("energize_tick_l");
		this.play_sound("clam_1.wav");
		this.s1 = 200;
		R.player.enter_main_state();
	}
}

if (this.s1 == 200) {
	if (this.try_to_talk(0, jr, false)) {
		this.dialogue("river", "keepers_after", 2);
		this.s1 = 201;
	}
	if (this.try_to_talk(0, dad, false)) {
		if (this.s2 == 1) {
			this.dialogue("river", "keepers_after", 3);	
		} else {
			dad.scale.x = 1;
			this.dialogue("river", "keepers_after", 0);		
		}
		this.s1 = 201;
	}
} else if (this.s1 == 201) {
	if (this.doff()) this.s1 = 200;
}
