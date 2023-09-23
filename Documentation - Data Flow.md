# Documentation: Data-Flow

Last Updated 2023/09/23

ETO's codebase is a little confusing, relying on a mix of hardcoded and python-supported tools to create all the metadata that gets used to generate a scene. I thought it'd be handy to have a quick guide on how each sort of thingy ends up incorporated into the game, from file on disk to something-in-the-game.

I'll try to avoid describing how to edit some of these files and leave that in the Editor documentation.
## Music
* Stored as OGG files in /assets/mp3/song
* Hard-coded into /Project.xml . The 'id' (the Song ID) refers to how the game will refer to it as an asset to be played.
* assets/mp3/songtriggers.txt is a hard-coded file that maps map names to Song IDs, and contains tiny scripts for cases where some maps play different songs depending on game state.
* Registry initializes SongHelper, which parses songtriggers.txt 
* TestState then uses SongHelper to play songs when it changes maps.
* SongHelper handles music fading, etc.

## Sound Effects
* sfx stored in assets/mp3/sfx as .ogg or .wav
* filename + metadata hard-coded into assets/mp3/sound.meta
* gen_SNDX_hx.py converts sound.meta into source/autom/SNDC.hx
* source/help/SoundManager.hx  parses sound.meta to determine if sound playback needs to be randomized at all
* SoundManager.hx plays sound effects

## Levels
### Tile Collisions / .bcsv / .tilemeta
* The in-game editor allows you to draw a tilemap in real-time, however, usually we would only draw this with a debug tileset (which would then be autotiled over with the Tiled software). Even the Ocean has 4 layers of tilemaps in each map (a map would e.g. be the entrance of Whiteforge, the lens puzzle room of Fay Rouge, etc.)
* The editor (source/help/Editor.hx) then exports the tilemap data as a .bcsv file
* All 4 layers of tile data, and tilemap dimensions, are stored in the .bcsv (big CSV, lol) plaintext files in assets/csv. The name of a bcsv file corresponds to the map in the game it's located in.
* The .tilemeta files in assets/tile_meta correspond to .png tileset files in /assets/tileset 
	* .tilemeta files define the behavior of each tile in tileset - e.g. slopes, dark gas tiles, etc.
	* They also define frame-based animation data
* Every map in the game is associated with one tileset - this data is defined under BG_HASH in /assets/world.map
	* There are some scripts that can autopopulate parts of world.map, more on that in the Editor FAQ
* Every tileset name must be listed underneath TILESET_LIST in world.map .
* In-game, when entering a new map, **load_next_map_data()** in TestState.hx contains the calls that set up the tilemap layers.

### Background Art / .tmx

* Backgrounds are stored in /assets/sprites/bg (bg for background), as .png files.
* The metadata for backgrounds being loaded are in world.map, under BG_LIST. Each line here contains various data: the id name of the background (for usage within world.map), the filename (relative to /bg/), and some other basic info.
* world.map also contains the PARALLAX_SETS section. Here, we define a set of background layers, which can be given an ID (e.g. SET_BRIDGE_1) and then used in the BG_HASH section of world.map to determine what set of background art a given map uses.
* For some background png files, there's a corresponding .tmx file. This is a file used for working in the Tiled tilemap editor, which we used, in conjunction with my own autotiling scripts, to tile levels like the power plants. We would then export .png files from Tiled. 
	* We tiled the levels in a debug tileset - 
	* and then the autotiling scripts would convert the .bcsv file into an autotiled .tmx file usable in Tiled, which could be polished.
	* Tiled then exports png files for use in-game.
* The python scripts for autotiling are in /bat/py/melos_stuff/autotmx.py . The "artist-friendly" frontend python script is autotmx_marina.py
	* More info on this script in the editor FAQ.
	* The tool is unfortunately a bit esoteric and related to our art workflow for the areas, artistic choices, etc. Thus it might be kind of hard to really use on one's own - if you'd like you can try to figure it out, but it's probably easier to find some other tiling solution
* In bat/py/, there are some python scripts that assist with creating new metadata for each map. they can all be run using cmd/shell/etc
	* add_tilemeta creates a template .tilemeta file
	* add_map creates a blank .ent (entity data) and .bcsv file
	* add_bg is a helper tool for updating world.map with new background layers

### Entities
* Entities are placed using the in-game editor, and stored as .ent files. They contain different layers, which are groups for sprite sorting. There are 4 entity layers - BBG (behind background), BG1, BG2, and FG (foreground). They are confusingly named...
* Generally, entities in the editor correspond to the same named script.
* How to edit entities is in the Editor FAQ, but TestState.load_next_map_data will use HF.load_map_entities to parse a .ent file, create all the entities, and populate their properties.
* Entity art - it's loaded through the entity .hx scripts - see [[#Art]] for some details
## Art
* How does a sprite appear in-game? It depends if it's an enemy/obstacle-like entity, or a "generic NPC" using the GenericNPC script.
* spritesheets are located in /assets/sprites
* /assets/misc/entity_spritesheets.son contain a json-esque notation that defines the location of a spritesheet, the size of its frames, and an ID corresponding to its animation metadata ("anim_set")
	* generic_npc.son contains similar data, but for stuff that appears as GenericNPC entities in-game, like NPCs, interactive consoles, etc.
	* items.son define the appearance of inventory items.
* Animations for all sprites are defined in animations.txt
	* e.g. 'retract 16 13,12,11,10 false' means
		* the animation 'retract' plays at 16fps, shows frames 13,12,11,10 and does not loop (loop=false)
* Haxe scripts (usually FlxSprite or MySprite) then load this data.
* The call that interfaces with this metadata/spritesheets is usually AnimImporter.loadGraphic_from_data_with_id
* GenericNPC.hx:load_generic_npc_data is what parses the generic_npc.son and entity_spritesheets.son file
* AnimImporter.import_anims is what parses the animation information (which is then used when entities load their animations/sprites)
* These files are all hand-edited unfortunately...

## Events/Cutscenes
* Event files are hand-written and stored in /assets/script
* There are two types of cutscenes - "Regular" and "Easy".
* I don't remember my exact rules for when I used one or the other, but I think for stuff that was more finicky/moving parts, I used "Regular", for stuff that was just moving/fading some layers, playing text, I used "Easy"

### Regular Cutscenes
* Written in haxescript (hscript) - stored as .hx files in /assets/script/cutscene/
* HaxeScript is a slimmer version of haxe that can be interpreted during the game.
* Regular cutscenes are usually run by source/entity/npc/GenericNPC.hx, though I think some other files might run haxe script at times.
* Regular cutscenes contain function calls to functions in GenericNPC, which is how a haxescript file modifies game state
* I believe GenericNPC is also responsible for pausing the player, etc, during cutscenes.

### Easy Cutscenes
* These are used for playing certain cutscenes - usually the ones where you don't see Aliph on the screen (e.g. meeting the mayor)
* They're written using a custom, linear event language. I'm not sure if there's documentation, but it's pretty easy to reverse engineer
* These are stored as .txt files stored in /assets/script/cutscene/easy
* They're interpreted and run in source/entity/ui/EasyCutscene.hx 
* EasyCutscenes only play when:
	* A GenericNPC makes a call to R.easycutscene (e.g. cutscene/2_town_intro/2d_mayor_intro.hx plays the "0d_mayor" easycutscene)
	* Tryign to enter certain doors that are locked how Door.hx uses R.easycutscene . E.g. Aliph looking up at the tower in Whiteforge Plaza in the intro.
		* In this case, whether or not a EasyCutscene plays is determined by a Door Entity's property pointing to a .hx haxescript file in assets/script/tool/doors/


## Player Input
* InputHandler gets most of the gamepad and keyboard input, then assigns it to actions which game code uses.
* JoyModule I believe is used for rebinding or assigning gamepads?

## Dialogue
* For some reason, dialogue/most localizable strings are stored as one giant file, per language, in /assets/dialogue/ . The top of the files explain the structure, but essentially, a line of dialogue is categorized at a high level by its "MAP" (e.g. dialogue playing in Whiteforge), then by its "SCENE" (dialogue for a cutscene, or an NPC)
* For the most part, dialogue was hard-coded - but - we did use this '/bat/py/melos_stuff/dialogue_formatter.py' script to replace simpler, human-readable tags with the game-readable ones. E.g., I could write "s=none" to denote  "\%%speaker%none\%%", and the python script would search and replace.
* source/help/DialogueManager.hx handles parsing the dialogue file, replacing button tags, and extracting other tags (like the 'pic' tag which defines the visible character portrait of the line)
	* This data is extracted and then used by /source/entity/ui/DialogueBox.hx 
* DialogueBox.hx is the code that shows the dialogue box, and prints the text out. If you look at "get_scripts", you can puzzle out what the various tags do.
	* One confusing tag is the 'speaker' tag - which will determine where the dialogue box is positioned and what it points to. 
	* When a speaker tag says 'g', it means it's going to point to a point on the map defined by a regular cutscene file - e.g. see script/cutscene/2_town_intro/2c_funeral.hx, which contains "make_child" calls which create and designate certain other NPCs as targets for the dialogue box
* Please note the Japanese localization was never finished and is incomplete
* There are tools that help with checking for formatting errors in /bat/py/melos_stuff

Lastly, journal info is all localized and crammed into assets/dialogue/journal.txt .

## Save Files

* Saving UI is done via source/help/SaveModule.hx
* Saving to text files is done in the reassuringly named "JankSave.hx". In particular they use my original method of choice, of just turning all save data into strings and writing it to a readable file.
## Other
### build_vars.son
* Contains variables you can change to change how the game runs. 
* Generally you only want to edit "START_STATE" which lets you start in different areas, as well as "EDITOR_IS_TOGGLEABLE"