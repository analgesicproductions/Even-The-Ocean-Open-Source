

# Documentation: Folder Structure

Last updated 2023/09/23

This document describes the folder structure of Even the Ocean's source code at a high level, through a 'top-down' description. For a 'reverse-engineering' description (e.g. 'What displays a dialogue box?') see DOCUMENTATION_CODE_EXPLANATION.md 

Some of these files/folders will come up in the code explanation - but if there's ever a mysterious file, just grep or search for the filename and you should be able to find where it is (or isn't) used.

## Table of Contents
* [[#Top-level]]
* [[#Assets folder]]
* [[#bat Folder]]
* [[#export Folder]]
* [[#Open Source Assets]]
* [[#Source Code]]
* [[#txt Folder]]

## Top-level
* playgame.bat - this is what Steam/etc use to launch the game and ensure the debug output is written to a logfile
* Project.xml - used in the build process to embed music and some folders, as well as set the base window resolution, FPS, program name
* \_noncrypt_assets: Mostly out of date, but the buf/ folder does store buffer mode files for the Editor. 
## Assets folder

**assets** - The files that are included into every build of the game.
* Top-level: 
	* entity_presets.son - unused(?) file that was used for 'presets' for various enemies
	* icon.ico - The icon for the .exe I think
	* prlx_TEST.hscript - Unused(?)
	* world.map - Relevant for the editor. defines metadata for the background layers. This file is in a bit more detail in the Data Flow documentation 
* csv - Tilemap data for each map
* data - Files for haxeflixel's internal debug views
* dialogue - Dialogue data files. Japanese is incomplete.
* map_ent - Entity data files for each map. Stored in plain text.
* misc
	* Top-Level - Various data files used (or not used) by the game for setting up sprite animations, debug modes, particle effects
	* crashdumper - Code that is/was used for showing various OS information during crashes
	* record - Plaintext data used for the Aliph ghosts in Magdal Woods, as well as the puzzle data for the energy laser minigames
* mp3
	* Top-Level - Metadata for determining what songs play where, SFX metadata, what SFX play on what ground surfaces
		* gen_SNDC_hx.py used for generating a .hx file that embeds the sound effects
	* sfx - Sound Effects/Ambient noises/Character Voice SFX
	* song - .ogg files for the music
* script - various hscript files used by code within the game
	* Top-Level - Some debug event files and a "template" (CUTSCENE_SKELETON.hx) for events. (Events are parsed via hscript and some of my own code)
	* cutscene
		* The numbered folders are 'more involved' events that involve movement or flag-based state changes
		* 'easy' is a simple event language I made that is for events that primarily show text
	* enemy - unused AI for broken enemy
	* nature - unused(?) AI for broken animals
	* person - NPC scripts and a few others
	* tool - misc scripts (like door conditions, sfx ambience looping, the journal)
	* trap - unused(?)
* sprites
	* bg - Background art layers, as well as .tmx files which were used with Tiled Editor to export pngs for the Power Plants
	* enemy - some enemy spritesheets
	* font - the bitmap fonts for languages
	* npc - NPC sprites etc
	* player - Aliph sprites and aliph-related sprites
	* set - 'setpieces' - sprite objects or overlays that could be placed in levels
	* test - not sure
	* tools - unused?
	* trap - entity spritesheets (usually harmful entities)
	* ui - UI, item assets
	* util - entity spritesheets (usually harmless ones)
	* tile_meta - Metadata used by the engine to define tilemap collisions
	* tileset - Tilesets used in maps. Some are old.


## bat Folder

Most of these scripts are related to managing/formatting data for the game. I'll go into more detail in the Editing FAQ.

* Top-level: updateflixel.bat is needed for installation
* py
	* Top-level
	* melos_stuff
* py/melos - These two scripts were used for creating PNG minimaps for various purposes. At one point there were scripts that would use other libraries to make graphs of the game's map connections! That was a fun project.
	* printboss.py: Printed minimaps for the "Boss" areas (the lens puzzle maps)
	* random_space.py: I think this did the same as above, but for any map

## export Folder

This is where the game is created when compiled. You would use this to ship the game.

## Open Source Assets

Needed during installation.
## Source Code



* Top-Level
	* Main.hx - the entry point for the code
	* ProjectClass.hx - the FlxGame for the game, highest-level update loop
* autom
	* EMBED_TILEMAP: Contains globals which store data for maps, etc. The game parses and fills out all the data on game launch, but the editor mode can also force a reload.
	* SNDC: Generated by gen_SNDC_hx.py - contains a mapping of variable names to filenames for sound effects
* entity - things Aliph/the player interacts with
	* Top-Level 
		* MySprite - a FlxSprite extension I made to interface with my in-game editor
	* enemy - entities that react/move near you, usually.
	* npc - misc entities - usually stationary, more puzzle-related, or sometimes very important, e.g.
		* GenericNPC - Roughly this is the 'play events' class for most of the NPCs. Most of the scripts in "script" use this class to actually do stuff to the main game.
		* SetPiece - An important entity used for the non-tile decorations throughout the game
	* player - Various scripts related to the player, including the controller. Also has old scripts like RealPlayer, Train.
	* tool - More 'engine-y' entities - that were still placed with the editor. 
		* Cutscene: This was supposed to play events, but I think it  got deprecated for GenericNPC, confusingly
	* trap - more hazard-esque entities found throughout the game.
	* ui - things related to maps, stuff in the UI. Some stuff is unused. Some is more important, like: 
		* PauseMenu: the pause menu
		* DialogueBox
		* EasyCutscene - these use the script/ files under easy/ - it was a higher-level language I made for some of the game's scenes.
	* util - A random assortment of things - usually entities that you interact with but they don't hurt you. Some of these went unused
* global
	* C - "Constants", I think? Mostly globals used throughout the game, esp. stuff for localized fonts
	* EF - variables used for managing game state/flags
	* Registry - static variables for game state, various globals, as well as unused code
* help - Everything else. A bunch of important scripts here, including:
	* DialogueManager - manages dialogue state, and getting dialogue
	* Editor - the code for the in-game editor (more on this in a separate document!)
	* EventHelper - functions sometimes called by other files (esp the hscript files?) for managing state, etc.
	* FlxX - flixel-related helper functions I made
	* HelpTilemap - functions for initializing tilemap metadata, handling callbacks, animated tiles
	* HF - helper functions
	* InputHandler - handles user input
	* JankSave - the actual saving code
	* SaveModule - Saving UI?
	* SongHelper - audio playback
	* SpriteFactory - called by the engine in order to create and place the entities in each map.
	* WarpModule - the UI used for starting the game in a skipped state
	* 
* state - various FlxStates
	* GameState -a FlxState existing above Test/Title for managing them
	* TestState - ironically I think this is the main gameplay loop that handles changing scenes, map loading, etc.
	* TSC - title screen related constants

## txt Folder

* Top-Level
	* .current - version number maybe? unused maybe
	* .npclock_off - something editor related
	* (Old) EDITOR_FAQ.txt - An outdated editor FAQ that is still partially correct
	* (Old) ENTITY_FAQ.txt - An outdated and incomplete FAQ explaining the entities/enemies you can place in the editor.
* addons - A file used in the flixel engine. See 'flixel'
* flixel - flixel engine. This is not actually compiled - you use the 'bat/updateflixel.bat' script to copy these files to the actual flixel haxe library.

