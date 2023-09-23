// Plays once upon entering town

// try to talk for children so (!) pops up
//forest_welcome_song
if (!this.child_init) { 
	this.child_init = true;
	this.make_child("forest_musicians",false,"flute_idle"); // Flute 
	this.make_child("forest_musicians",false,"guitar_idle"); // guitar 
	this.make_child("forest_musicians",false,"tuba_idle"); // tuba
	this.make_child("vale",false,"idle"); // vale
	this.make_child("dolly_noscript",false,"idle_l"); // dolly
	this.make_child("gunPoof",false); // smoke1
	this.make_child("gunPoof", false); // smoke2
	this.make_child("gunPoof", false); // smoke2
	this.visible = false;
	// Create trigger for cutscene
	if (this.get_scene_state("forest", "enter_town", 1) == 0) {
		this.has_trigger = true;
		this.make_trigger(this.x, this.y-170, 20, 200);
	}
}	

var flute = this.sprites.members[0];
var guitar = this.sprites.members[1];
var tuba = this.sprites.members[2];
var vale = this.sprites.members[3];
var dolly = this.sprites.members[4];
var smoke1 = this.sprites.members[5];
var smoke2 = this.sprites.members[6];
var smoke3 = this.sprites.members[6];



if (this.s1 == 0) {
	// Don't play this if we've played the scene already.
	if (this.s2 == 0) {
		if (this.get_scene_state("forest", "enter_town", 1) != 0) {
			this.s1 = 100;
			this.set_vars(flute, this.x + 32, this.y,1);
			this.set_vars(tuba, this.x + 64, this.y,1);
			this.set_vars(guitar, this.x + 96, this.y, 1);
			
			this.set_vars(vale, this.x + 120, this.y, 1);
			this.set_wh(flute, 16, 32);
			this.set_wh(tuba, 16, 32);
			this.set_wh(guitar, 16, 32);
			return;
		} else {
		// Make the NPCS visible and idle.
			this.s2 = 1;
			this.set_vars(flute, this.x + 32, this.y,1);
			this.set_vars(tuba, this.x + 64, this.y,1);
			this.set_vars(guitar, this.x + 96, this.y,1);
			this.set_vars(vale, this.x + 120, this.y, 1);
			this.set_wh(flute, 16, 32);
			this.set_wh(tuba, 16, 32);
			this.set_wh(guitar, 16, 32);
		}
	} else if (this.s2 == 1) { 
		// On trigger, start the music and pause player .
		if (R.player.overlaps(this.trigger)) {
			this.s2 = 2;
		}
	} else if (this.s2 == 2) {
		if (this.player_freeze_help()) {
			this.s1 = 1;
			this.s2 = 0;
			R.player.enter_cutscene();
			this.play_music("forest_welcome_song");
			tuba.animation.play("tuba_play");
			flute.animation.play("flute_play");
			guitar.animation.play("guitar_play");
		}
	}
} else if (this.s1 == 1) {
	// song plays enough, then interrupted by smoke from 
	if (this.s2 == 0) {
		this.t_1 ++;
		
		dolly.x -= 16;
		if (this.t_1 == 60 * 24) {
			this.play_music("null");
			this.play_sound("splash.wav");
			this.set_vars(dolly, tuba.x, tuba.y,1);
			this.set_vars(smoke1, dolly.x, dolly.y, 1);
			smoke1.animation.play("d");
			tuba.animation.play("tuba_idle");
			flute.animation.play("flute_idle");
			guitar.animation.play("guitar_idle");
		} else if (this.t_1 == 60 * 24 + 10) {
			this.set_vars(smoke2, dolly.x+10, dolly.y-10, 1);
			smoke2.animation.play("d");
		} else if (this.t_1 == 60 * 24 + 20) {
			this.set_vars(smoke3, dolly.x-10, dolly.y-10, 1);
			smoke3.animation.play("d");
			this.t_1 = 0;
			this.s2 = 1;
		}
		dolly.x += 16;
	// After the smoke fades, Vale talks.
	} else if (this.s2 == 1) {
		this.t_1 ++;
		if (this.t_1 == 60) {
			this.t_1 = 0;
			this.s2 = 2;
			this.dialogue("forest", "enter_town", 0, false);
		}
	// Vale and dolly leave, then the player can move again.
	} else if (this.s2 == 2) {
		if (!this.dialogue_is_on()) {
			dolly.animation.play("idle_l");
			//dolly.velocity.x = -100;
			this.s2 = 3;
		}
	} else if (this.s2 == 3) {
		dolly.alpha -= 0.04;
		if (dolly.alpha <= 0) {
			R.player.pause_toggle(false);
			R.player.enter_main_state();
			dolly.exists = false;
			this.play_music("forest_cheesy_town");
			this.dialogue("forest", "enter_town", 2);
			this.s1 = 2;
			this.s2 = 0;
		}
	}
} else if (this.s1 == 2) {
// aliph can talk tot he musicians now
	if (this.try_to_talk(0, tuba) || this.try_to_talk(0, guitar) || this.try_to_talk(0, flute)) {
		this.dialogue("forest", "musicians", 0);
		return;
	}
	if (this.try_to_talk(0, vale)) {
		this.dialogue("forest", "vale_2");
		return;
	}
	
}  else if (this.s1 == 100) {
// after the first scene, only the guitarist remains
	if (this.try_to_talk(0, tuba) || this.try_to_talk(0, guitar) || this.try_to_talk(0, flute)) {
		this.dialogue("forest", "musicians", 0);
	}
	if (this.try_to_talk(0, vale)) {
		this.dialogue("forest", "vale_2");
		return;
	}
}
	

