//{ ronald
if (!this.child_init) {
	this.child_init = true;
	
	if (this.event(39)) {
		this.only_visible_in_editor = true;
		this.SCRIPT_OFF = true;
		return;
	}
	
	this.s1 = 0;
	this.make_child("ronald_bird",false,"white_idle"); // 
	this.make_child("ronald_bird",false,"white_idle"); // 
	this.make_child("ronald_bird",false,"white_idle"); // 
	this.make_child("ronald_bird",false,"white_idle"); // 
	this.make_child("ronald_bird",false,"rag_idle"); // 
	this.make_child("ronald_bird",false,"rag_idle"); // 
	this.make_child("ronald_bird",false,"rag_idle"); // 
	this.make_child("ronald_bird", false, "rag_idle"); // 
	this.make_child("ronaldSprite");
	
	this.sprites.members[8].x = this.x - 48;
	this.sprites.members[8].y = this.y;
	this.sprites.members[8].exists = true;
	
	this.only_visible_in_editor = true;
	
//{ ronald_bird
//
//white_fly 12 0
//white_idle 12 0
//rag_fly 12 1
//rag_idle 12 1

//this._trace("debug ronald");
//this.s1 = 1;
}

var w1 = this.sprites.members[0];
var w2 = this.sprites.members[1];
var w3 = this.sprites.members[2];
var w4 = this.sprites.members[3];
var r1 = this.sprites.members[4];
var r2 = this.sprites.members[5];
var r3 = this.sprites.members[6];
var r4 = this.sprites.members[7];
var ronald = this.sprites.members[8];

var timmer = 15;
if (this.s1 == 0) {
	if (this.try_to_talk(0,ronald)) {
		if (1 == this.get_ss("city", "ronald", 1)) {
			this.dialogue("city", "ronald", 3); // Shorter talk
		} else { 
			this.dialogue("city", "ronald", 13); // First talk - Sets ss1 to 1
		}
		this.s1 = 1; // always asks y/n/candy
	} 
} else if (this.s1 == 1) {
	if (this.doff()) {
		//if (this.d_last_yn() == 0) {  // yes
		if (this.d_last_yn() == 0) { 
			// start game
			this.s1 = 3;
			this.state_1 = 0;
			this.state_2 = 0;
			this.t_1 = 0;
			this.tm_2 = -1; // used for the fly-in
			this.s2 = 1;
			
	//private function af(idx:Int, val:Dynamic, set:Bool = true, init:Bool = false):Dynamic {
			this.af(4, 0, false, true);
			//this._trace(this.help_array);
			for (i in [0, 1, 2, 3, 4, 5, 6, 7]) {
				this.sprites.members[i].ID = -1;
				this.sprites.members[i].exists = true;
				this.sprites.members[i].visible = true;
				this.sprites.members[i].move( -16, -16);
			}
			this.t_2 = 0;
		} else if (this.d_last_yn() == 1) {  // no
			this.s1 = 0;
		} else if (this.d_last_yn() == 2) {  // candy
			this.s1 = 0;
		}
	}
} else if (this.s1 == 2) {
	if (this.doff()) {
		this.s1 = 0;
	}
} else if (this.s1 == 3) {
	this.t_1 ++;
	if (this.t_1 > timmer * 60) {
		if (this.player_freeze_help()) {
			if (this.doff()) {
				this.dialogue("city", "ronald", 12);
				this.s1 = 13;
				this.s2 = 2;
			}
		}
		return;
	}

	if (this.try_to_talk(0,ronald)) {
		this.dialogue("city", "ronald", 10);
		this.s1 = 4;
	}
	
	// somehow count birds?
	// state_1 = # of Ragbirds (ones to scare)
	// state_2 = # of Snowlets - ones to not scare
	// 3 outcomes: |S-R| <= 1, else, R > S or S < R
} else if (this.s1 == 13 && this.doff()) {
	if (this.try_to_talk(0,ronald)) {
		
		this.s1 = 0;
		if ( -1 <= this.state_1 - this.state_2 && 1 >= this.state_1 - this.state_2) {
			this.dialogue("city", "ronald", 6);
		} else {
			if (this.state_1  < this.state_2) { // not enough ragbirds!
				this.dialogue("city", "ronald", 4);
			} else {
				this.dialogue("city", "ronald", 8);
			}
		}
	}
} else if (this.s1 == 4 && this.doff()) {
	this.s1 = 3;
	
} else if (this.s1 == 5 && this.doff()) {
	if (this.try_to_talk(0,ronald,true)) {
		this.s1 = 6;
		this.dialogue("city", "ronald", 11);
	}
} else if (this.s1 == 6 && this.doff()) {
	this.s1 = 5;
}

// Bird logic
if (this.s2 == 1 || this.s2 == 2) {
		// Loop 1: uses t_2 to set a timer for sending a bird

		if (this.t_2 == 0 && this.s2 == 1) { // Every 3-5 seconds, pick a random bird type whose ID is -1
			if (this.tm_2 >= 0 || this.s1 > 4) { // dont fly in when done
				
			} else {
			this.t_2 = this.rand_int(30, 90);
			
			//this._trace(this.t_2);
			var idx = this.rand_int(0, 8); // Dumb way of picking a random pt to search from
			
			for (i in [0, 1, 2, 3, 4, 5, 6, 7]) {
				if ( -1 == this.sprites.members[idx].ID) {
			//this._trace("bird");
			//this._trace(idx);
					break;
				}
				idx = (idx + 1) % 8;
			}
		
			// pick a random birdcoop that's available	
			var idx2 = this.rand_int(0, 4);
			//this._trace(idx2);
			//this._trace("birdhouse");
			for (i in [0, 1, 2, 3]) {
				if (this.af(idx2, 0, false) == 0) {
					//this._trace(idx2);
					this.af(idx2, 1);  // mark as taken
					this.sprites.members[idx].ID = -3 - idx2; // set ID to -3 - houseidx
					
					// First, move it to the birdhouse.
					this.sprites.members[idx].move(this.x + 48 * idx2, this.y - 32);
					// Then, offset it, set vel and accel to stop it at the birdhouse exactly
					if (this.rand_int(0, 2) == 0) {
						this.sprites.members[idx].x -= 32;
						this.sprites.members[idx].velocity.x = 64;
						this.sprites.members[idx].acceleration.x = -64;
						this.sprites.members[idx].scale.x = -1;
					} else {
						this.sprites.members[idx].x += 32;
						this.sprites.members[idx].velocity.x = -64;
						this.sprites.members[idx].acceleration.x = 64;
						this.sprites.members[idx].scale.x = 1;
					}
					this.sprites.members[idx].y -= 256;
					this.sprites.members[idx].velocity.y = 512;
					this.sprites.members[idx].acceleration.y = -512;
					this.tm_2 = 60;
					if (idx <= 3) {
						this.sprites.members[idx].animation.play("white_fly",true);
					} else {
						this.sprites.members[idx].animation.play("rag_fly",true);
					}
					
					break;
				}
				idx2 = (idx2 + 1) % 4;
			}
	//private function af(idx:Int, val:Dynamic, set:Bool = true, init:Bool = false):Dynamic {
			}
		} else {
			this.t_2--;
		}
		
		
		// Second loop: iterates through birds to update their states
		for (i in [0, 1, 2, 3, 4, 5, 6, 7]) {
			var iid2 = this.sprites.members[i].ID;
			if (iid2 <= -3) { // fly in logic
				this.tm_2 --;
				if (this.tm_2 < 0) {
					var iid = (this.sprites.members[i].ID + 3) * -1; // -6 to -3 turns to 3 to 0 - used to set an initial position
					this.sprites.members[i].velocity.set(0, 0); //set its velocity to go to it, 
					this.sprites.members[i].acceleration.set(0, 0); //set its velocity to go to it, 
					this.sprites.members[i].move(this.x + 48 * iid, this.y - 32); // snap position
					this.sprites.members[i].ID = this.rand_int(150, 240);// when bird reaches coop, set ID
					if (i <= 3) {
						this.sprites.members[i].animation.play("white_idle",true);
					} else {
						this.sprites.members[i].animation.play("rag_idle",true);
					}
				}
			} else if (iid2 == -2) { // fly away logic
				// when offscreen set ID to -1
				if (this.sprites.members[i].y < this.y - 256) {
					this.sprites.members[i].velocity.set(0, 0); //stop it from moving
					this.sprites.members[i].ID = -1; //stop it from moving
				}
				
			} else if (iid2 >= 2) {
				if (this.s1 <= 4) this.sprites.members[i].ID -= 1; // tick down, but not when game is done.
				
				// if touched by player, do above, but increase state_1 or state_2
				if (R.player.overlaps(this.sprites.members[i])) {
					
					this.sprites.members[i].ID = 1;
					if (i <= 3) {
						//this._trace("state 1");
						this.state_1 ++;
					} else {
						//this._trace("state 2");
						this.state_2 ++;
					}
				}
				
				// when ID == 1 bc of player overlapping, set ID to -2 and fly away, set birdcoop as available
				if (this.sprites.members[i].ID == 1) {
					this.sprites.members[i].ID = -2;
					var xx = this.sprites.members[i].x;
					if (xx == this.x + 48 * 0) {
						this.af(0, 0);
					}
					if (xx == this.x + 48 * 1) {
						this.af(1, 0);
					}
					if (xx == this.x + 48 * 2) {
						this.af(2, 0);
					}
					if (xx == this.x + 48 * 3) {
						this.af(3, 0);
					}
					
					if (i <= 3) {
						this.sprites.members[i].animation.play("white_fly",true);
					} else {
						this.sprites.members[i].animation.play("rag_fly",true);
					}
					this.sprites.members[i].velocity.y = -200;
					
					if (this.rand_int( -3, 3) > 0) {
						this.sprites.members[i].velocity.x = this.rand_int( 24, 48);
					} else {
						this.sprites.members[i].velocity.x = this.rand_int( -48, -24);
					}
					
					if (this.sprites.members[i].velocity.x >0) {
						this.sprites.members[i].scale.x = -1;
					} else {
						this.sprites.members[i].scale.x = 1;
					}
				}
			} else {
				
			}
		}
}