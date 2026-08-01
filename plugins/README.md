# How to create plugin for SCP: Continued Procedures?
⚠️ Currently, only puppets are supported!
## Plugin structure
Plugins are stored in %APPDATA%\SCPContPr\mods\puppets\custom\ (on Windows) or ~/.local/share/SCPContPr/mods/puppets/custom/ (on ^nix/Linux)

Structure of a plugin:
```
~/mods/puppets/custom/:
|- 📁<plugin_name>
|  |- 📁scripts
|  |  |- <your scripts with .gompl extension>
|  |- 📄plugin.json
|  |- 📄<your_3d_model>.glb

```

## GOMPL
SCP: Continued Procedures uses [GOMPL](https://github.com/ratkingsminion/gompl) as scripting language.



## plugin.json structure

```
{
	"name": `enter your plugin name (string)`, 
	"author": `enter your username (string)`,
	"year": `current year (int)`,
	"license": `license (usually CC-BY 4.0, CC-BY-SA 4.0/3.0)`,
	"plugin_type": `"puppet"`,
	"gltf": {
		"gltf_file_prefix": `model prefix (generally, model's filename) (string)`,
        "gltf_file_suffix": `specific suffixes, made specially for SCP-131 (string)`,
        "gltf_path_to_find": `path to your gltf AND a plugin as whole (string)`
    },
    "puppet_resource": { `see more information at {project_root}/src/PlayerScript/PlayerClassResources/PuppetResource.gd`
        "speed": `speed of the puppet (float)`,
        "spawn_point_group": `Group, where the game find spawnpoints (string)`,
        "initial_amount": `Initial amount to spawn (int)`,
        "interacting_action": `(int)`,
            `0 - None - other player will do nothing`
            `1 - Follow - other player will follow you`
            `2 - Special action - Other player will do something if you interact`
        "fraction": `0 is human, 1 is hostile SCP, 2 is vision SCP (like 650 and 173), 3 is must-not-look SCP (like 023) (int)`,
        "team": `Only for humans currently.`
               `0 is none team, 1 is Foundation personnel, 2 is Class-D personnel,`
               `3 is Chaos Insurgency (int),`
        "wandering_system": `(int)`
           `0 - None - player will not wander at all.`
           `1 - Generic wander is MovableNpc wander implementation`
           `2 - Special wander is limited wander - just moving from point to point.`
        "special_wandering_group": `Group of points for WanderingSystem.LIMITED_WANDER (string)`,
        "health": `[
           `100.0, - necessary, but you can change it.`
           `50.0, - all of the others are`
           `50.0, optional, but if you use SkinnableHumanPuppetScript,`
           `50.0 - please use these values below.`
       `],`
       "enable_avoidance": `If you want to enable navigation avoidance (bool)`,
       "spawn_on_start": `Check if your puppet spawns on start (bool, has niche usage)`,
       "puppet_navigation_layers": `Navigation layers (int)`,
       "enable_ik": `For humans only - enable face inverse kinematics (bool)`,
       "disable_move_on_slide": `Disable physics check for puppet (bool)`,
       "can_ride": `can ride the elevator (bool)`,
       "start_items": `[] start items (int array)`,
       "start_money": `{} start money (dictionary with string as key and int as value)`,
       "enable_advanced_ai": `Enables picking advanced AI (bool, has niche usage)`,
       "immortal": `Godmode (bool)`,
       "keycards": `[] keycards available (int array, has niche usage)`
    }
}
```

## Script naming
All files must have extension `.gompl`

### Common

`start.gompl` - does the same, as `_ready` function (from Godot). Supported in all SkinnablePuppetScripts.

`update.gompl` - does the same, as `_physics_process` function (from Godot). Supported in all SkinnablePuppetScripts.

### Built-in classes

`attack.gompl` - do something, when attacking. Only supported with SCP-1507 and SCP-939.

`blink_started.gompl` - do something, when blink started. Only supported with SCP-347.

`blink_ended.gompl` - do something, when blink ended. Only supported with SCP-173 and SCP-347.

`crunch.gompl` - do something on neck snap. Only supported with SCP-173.

`teleport.gompl` - do something on teleport. Only supported with SCP-650.

### Custom classes
#### Scripts

`custom_action_1.gompl`, `custom_action_2.gompl`, `custom_action_3.gompl`, `custom_action_4.gompl` - do something in these 4 functions.

`special_action.gompl` - do something on interaction.

`player_entered_vision_area.gompl` - do something, if puppet goes into vision trigger.

`player_exited_vision_area.gompl` - do something, if puppet is leaving vision trigger.


`player_entered_trigger.gompl` - if protagonist entered user-defined trigger

`puppet_entered_trigger.gompl` - if NPC entered entered user-defined trigger

`player_exited_trigger.gompl` - if protagonist exited user-defined trigger

`puppet_exited_trigger.gompl` - if NPC exited user-defined trigger

#### Functions
`spawn_trigger(shape, size, collider_rotation_x, collider_rotation_y, collider_rotation_z, position_from_center_x, position_from_center_y, position_from_center_z, height)`- Spawns trigger (if it does not already exist), where
`shape` is enum (use as int in GOMPL):
```
0 is Sphere shape
1 is Box shape
2 is Capsule shape
3 is Cylinder shape
```
`size` is primary size or radius (float).
`collider_rotation_x`, `collider_rotation_y`, `collider_rotation_z` is rotation of collider (floats, defaults to 0)
`position_from_center_x`, `position_from_center_y`, `position_from_center_z` is position of an Area3D from center (floats, defaults to 0)
`height` - for usage with Capsule and Cylinder shapes, defaults to 1.0.

#### Getters-setters
> ⚠️ Due to GOMPL limitation, getters are implemented as global variables, started with `builtin_`,
> such as `builtin_follow`, `builtin_player_global_pos_x`, etc...

`get_distance_to_player()` Gets distance to player (`builtin_distance_to_player`)

`get_player_front_facing` - Gets global_transform.basis.z of self (`builtin_player_front_facing_x/y/z`)

`get_front_facing()` - Gets global_transform.basis.z of self (`builtin_front_facing_x/y/z`)

`get_player_global_position()` - Gets protagonists' global position as 3 floats (`builtin_player_global_pos_x/y/z`)

`get_global_position()` - Gets position of self as 3 floats (`builtin_global_pos_x/y/z`)

`set_global_position(x: float, y: float, z: float)` - Sets position of self

`get_follow()` - Gets follow path, which self follows (`builtin_follow`)

`set_follow(path: String)` - Sets follow path, which self follows

`get_immortal()` - Gets godmode status (`builtin_immortal`)

`set_immortal(value: bool)` - Sets godmode status

`get_movement_freeze()` - Gets movement freeze of self (`builtin_movement_freeze`)

`set_movement_freeze(value: bool)` - Sets movement freeze on self

`player_health_manage(health_to_add: float, health_type: int = 0, deplete_reason: String = "")` - Adds or depletes health for player

`health_manage(health_to_add: float, health_type: int = 0, deplete_reason: String = "")` - Adds or depletes health for self

`add_item(item_id: int)` - Adds item to self

`player_add_item(item_id: int)` - Adds item to player

`remove_item(item_id: int, drop: bool = false)` - Remove item from self

`player_remove_item(item_id: int, drop: bool = false)` - Remove item from player