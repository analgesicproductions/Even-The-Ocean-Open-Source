# Editor

Last updated 2023/09/23

Even the Ocean features an in-game Editor. While it certainly works, it's not really ideal. Still, if you'd like to try it out, I want to provide some simple instructions!

With these you should be able to make your own levels and own game, although since entities/other stuff are undocumented you'll likely need to read code a bit. Maybe one day someone will make better tools or docs! In the meantime...
## To-Do:

* Document Tile mode better (though I think this is mostly self explanatory - note you can click and drag the tile pane via the top-left. it also has save/load controls)
* Document Buffer Mode better (you can read the source code if you want - the idea here is that you can click and drag, and it will save the tiles/entities you've selected into )
* Explain a bit of the autotile python script and interaction with Tiled editor
* Explain event editing workflows?
* adding npc example

## Getting Started

1. First, you need to set the game to run in developer mode. This is simple - just open '/assets/misc/build_vars.son', a plaintext file.
2. First, set "DEV_MODE_ON" to 1 (change the 0 to a 1). I think this makes it so the editor now reads its files from the working directory (i.e., /assets/csv, vs. /export/windows/... )
3. Second, set EDITOR_IS_TOGGLEABLE to 1. This lets you use a keyboard shortcut with the game running to open the editor.
4. Last, set START_STATE to 1 - this will drop you straight into a map, rather than the title screen.
5. Note that when exporting the game you want to set these all back to 0.

### Screen Flash Warning

The editor unfortunately uses some full-screen flash effects for visual feedback. You can turn these off by going to the pause menu in-game and turning off screen flashes in Gameplay Settings.

You can also just turn these off in-engine by going to CameraFrontEnd.hx in Flixel and modifying flash(). (Note you'll want to edit the file in the working directory and then use the flixel copy script to copy that changed file to the compiled haxe library for flixel.)

If you don't want to make a game-wide change you can just change flash() in Editor.hx as well.

### Note on /assets vs /export/windows/bin/assets

Whenever you build the game, all modified assets are copied from the working directory (/assets/) to the export directory (/export/windows/bin/assets). However, the editor only loads and writes files from the working directory (/assets/). Generally speaking when working on the game you don't want version control to pick up anything in /export/.

### Picking where to start

In TestState.hx, you can set MAP_NAME, next_player_x/y as needed to change where the game loads when starting up.


## Using the Editor

* Most Editor code runs out of Editor.hx.
* The code for displaying/hiding the editor is in GameState.hx (search EDITOR_IS_TOGGLEABLE)
### Opening the Editor
* Simply press SPACE+E to open the editor. CTRL+ALT+E also works. 
* Same for closing. 
* When exiting, you'll be prompted to save the entity and tilemap data (.ent and .bcsv files) by pressing y or n and hitting ENTER.
### Navigation
* Hold SHIFT and move the mouse to the edges to pan
* SHIFT + Arrow Keys will scroll faster
* Press Z to zoom in or out.
* Press P to snap Aliph to the cursor.
* Tab will hide/show some of the UI
* CTRL+M mutes/unmutes
### Basic UI
* Bottom row: 
	* shows mouse X/Y, relative to the map,
	* as well as tile coordinates (map-relative)
	* Map name
	* Map width and height in tiles
* In the top-right are four icons.
	* RED square - ?
	* Pod - toggle with E. determines whether entities are placed as Dark or Light by default
	* ;+P chk - When clicked, sets the checkpoint for the player after a death
		* When playing, press ;+P to warp Aliph to the checkpoint.
	* EN Lock - Toggle by clicking. When ON (no Red X showing), Aliph can gain energy but not die.
### Usability Note
Generally speaking the Editor is kind of touchy. If something seems weird you can usually exit the editor and re-enter to fix it, or change mode at any time.
### Modes

There are five modes - Add Entity, Tile, Edit Entity, Change Map, and Buffer Mode.

#### Add/Move/Delete Entity

This mode is used for moving, adding and deleting entities from the game, and a few other things. There are 10 pages of entities to select from.

* Press CTRL+A to enter this mode.
* update_mode_add_entity() for code
* Snap Player to Mouse: P
* Change Entity Page:  A/D, or ALT+Number
* Change Highlighted Entity within Page: W/S to navigate this list, or number keys

You are always modifying entities within a sorting group: BBG, BG-1, BG-2, and the confusingly named FG-2. (Behind-background, background 1, background 2, foreground)

To change which sorting group you're adding to, press CTRL+1  (BG1), 2 (BG2), 4 (FG2), or 0 (BBG).

* Move Entity (Including Player): CTRL + Left-Click + Drag Mouse. By default this snaps to the grid. Additionally, hold SHIFT to not snap.
* Move Multiple Entities:
	* Press "R" - editor will say "Toggled big Add mode"
	* Click and drag to make a blue box around entities to move. This is a little fiddly
	* Click again to confirm the blue box
	* Click the blue box, now you can see a red box denoting the new position
		* Now: Click again to confirm new position for entities
		* Press V to paste the entities (you can do this repeatedly)
		* Press P to paste the entities once
		* Press D to delete
		* Press "1" to do something mysterious (I don't understand what this does)
* Add entity: ALT + Left-Click
* Delete Entity: ALT + Q or D + Left click
* Copy/Paste Entity: SHIFT+C while above entity's clickable hitbox, SHIFT+V anywhere else
* Select Entity: Click on it. Note that the visible sprite doesn't always correspond to where you need to click.
	* WHEN SELECTED, you can do the below:
	* The entity's sorting order will be shown.
	* Change entity's sorting order: -/\_ or =/+
	* Change entity's sorting group: CTRL + +/-
		* *Fiddliness Warning*: If you move an entity into another sorting group, you won't be able to click it again without changing the active sorting group.
	* Move by pixels: arrow keys

* Save entity data: SHIFT+S
* Load entity data: SHIFT+L
	* Inexplicably this also reloads the dialogue data and other stuff.
	* Hold CTRL as well to skip loading dialogue which will make reloading fasterr

##### Door Helper

This is a useful tool for creating connections between two doors that you want to connect, within a scene or between scenes.

1. Press SHIFT+D to start DoorHelper. 
2. Add a new door entity, or click on an existing door.
3. Save the entity data
4. Optionally, change scene
5. Click on, or add another door
6. Editor will say "Doors linked between..."
7. Save entity data in both scenes.

##### Place Setpieces

There are certain pre-defined sprites you can place, depending on the area. When you're in a valid map with setpieces:

* Change Setpiece Group: V/B 
* Change index with Setpiece Group: X/C

When changing the setpiece to be played, its sprite will flash on screen.

To add a setpiece, you have to add the SetPiece entity (Page 9, entity 1)

Setpiece Metadata is located in /assets/misc/generic_npc.son under \_SetPiece . It contains up-to-date instructions on how to add your own.

#### Edit Entity Mode

* Access with CTRL+E.
* Click on an entity to show its properties.
* Use arrow keys to see other properties (if more than 10)
* Enter a number to start editing a property
* Editor text at bottom will say "New value for PROPERTYNAME"
* Enter the new value and hit enter
* The game does some data validation, but maybe something bad will happen if you enter bad data.

##### Determining what properties do

...Unfortunately you'll have to read the source code yourself... sorry. If you're interested enough to be reading this though I'm sure you can figure it out! Happy to answer questions, though.

##### Adding Children

Sometimes entities have a list of children - which are linked up by "GEID" - "Good enough IDs", (or global entity ids?) which are sort of unique IDs meant to let you connect entities.

Anyways, consider the SapPad entity. To add a child (so it can send energy to it)

* Hold C, and click on the SapPad.
* Editor should say at the top: "Now click the child"
* Click the child (e.g., a RaiseWall)
* Now if you look at the SapPad's properties again, children should contain an ID for the SapPad.


##### Presets (Broken)

While we didn't use this much in development, if you press P, it'll show presets for the entity type, defined in /assets/entity_presets.son.

You can then enter the number of a preset to change the properties. 

I think this is broken though.


#### Change Map Mode

This mode can be used to make new maps, but it's better to use the add_map.py python script, as even after making and saving the new .ent and .bcsv files you'll still need to upload world.map (or the editor will crash when trying to load the new map)

* Load map: L
	* Enter the map name to travel to and hit enter.
* Change map dimensions: S
	* You can resize the tilemap here if you want. this is destructive
* Fast-map-switch: ALT + NUMBER
	* See "editor_fast" in generic_npc.son
	* If the map you are in matches any of the entries, then pressing a number will warp you to that map in the set
	* E.g., if you're in SEA_1, then pressing 1-8 will warp you to those SEA rooms.
	* But if you were in "OTHERMAP_1", pressing numbers does nothing.
* Move Backgrounds: SHIFT+B
	* Bottom of editor now says BG MOVE IS ON: TRUE
	* Press "1" to move within BG layers, "2" to move within BG1 layers, as defined in world.map
	* Arrow keys to move by pixel, SHIFT+Arrow to move by tiles
	* Q/W to select a background layer within a background layer set to move
	* To see this in action, try out FALLS_G1.

#### Tile mode

CTRL+T to access

There's eyedropper, mass-place/delete, you can drag the tile palette, and use WASD to navigate it (you can scroll lower with W/S)

The only tileset we used in-editor is the debug ones/simple ones. I think that the tileset used is defined in world.map next to the map's name (e.g. FALLS_G1 uses FALLS tileset with FALLS tilemeta)

TO DO... more info


#### Buffer Mode

Mode is primarily used for editing levels, or from making level ideas in a single scene then copying them over to another scene and arranging.

Click and drag (like mass-select in ADd Mode) to select entities/tiles

* You can then click again to move, OR (while something's selected)
* hit S to save, use WASD to choose the slot, then ENTER to save
	* the file will be saved to \_noncrypt_assets/buf


* In (S/L/C) mode, L lets you load. You can also use WASD to select the slot.

* When in (S/L/C) mode, C lets you switch what set of buffers you're saving to. But you probably can just use NPC and be fine. I forget where these sets are defined.
* 

TO DO






