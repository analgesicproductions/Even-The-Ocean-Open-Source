//Test with Space+Q
var cut = "final_humus";
//var cut = "mayorfight";
//var cut = "yara_after_radio";
//var cut = "yara_final";
//var cut = "after_radio_depths";
//var cut = "ending_enter_wf";

//--final storyteller scene (SCENE final_humus)
if (cut == "final_humus") {
	this.change_map("WF_LO_1", 39, 13, true);
	this.set_ss("ending", "flood", 1, 1);
	this.set_ss("ending", "init_yara", 1, 1);
	this.set_ss("cutTEST", "a", 1, 1);
	this.set_event(18);
	this.set_event(47);
	this.set_event(48);
}


//--confrontation with mayor (SCENE mayor) - rainy + sunset
if (cut == "mayorfight") {
	this.change_map("WF_HI_1", 15, 15, true);
	this.set_ss("ending", "city_enter", 1, 1);
	this.set_ss("ending", "outside_wf", 1, 1);
	this.set_ss("ending", "mayor", 1, 0);
	this.set_ss("ending", "init_yara", 1, 0);
	this.set_event(48);
	this.set_event(18);
	this.set_event(47, false);
}
//-- Enter wf after beating karavold (should be rainy and sunset)
if (cut == "ending_enter_wf") {
	this.set_event(18);
	this.change_map("WF_LO_0", 15, 15, true);
	this.set_ss("ending", "outside_wf", 1, 1);
	this.set_event(48);
	this.set_event(47, false);
}


//--aliph reunite with Yara after radio tower (SCENE init_yara)
if (cut == "yara_after_radio") {
	this.set_event(18);
	this.set_event(19);
	this.set_event(47);
	this.set_event(48);
	this.set_ss("ending", "init_yara", 1, 0);
	this.set_ss("ending", "outside_wf", 1, 1);
	this.change_map("WF_LO_1", 42, 13, true);
}


//--final yara/aliph (SCENE yara_final)
if (cut == "yara_final") {
	this.set_event(18);
	this.set_event(19);
	this.set_event(47);
	this.set_event(48);
	this.change_map("WF_LO_1", 39, 13, true);
	this.set_ss("ending", "flood", 1, 1);
	this.set_ss("ending", "init_yara", 1, 1);
	this.set_ss("ending", "outside_wf", 1, 1);
	this.set_ss("cutTEST", "a", 1, 0);
}

//--After the laser-charge/geome destruction sequence - destruction only
if (cut == "after_radio_depths") {
	this.set_event(48);
	this.set_event(47, false);
	this.set_event(18, false);
	this.set_ss("ending", "outside_wf", 1, 0);
	this.change_map("WF_HI_1", 40, 15, true);
	
	this.set_ss("i2", "aliph_out", 1, 1);
	this.set_ss("i2", "crowd", 1, 1);
	this.set_ss("i2", "humus_jail", 1, 1);
	this.set_ss("i2", "yara", 1, 1);
}


