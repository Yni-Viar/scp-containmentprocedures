extends Node
## Save system
## Created by Yni, licensed under dual license: for SCP content - GPL 3, for non-SCP - MIT License

@export var save_data: Dictionary = {
	"map_seed": "",
	"location": Vector3.ZERO,
	"quest_progress": 0,
	"scp": 10,
	"current_day": 0,
	"scp_023": false
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

## Loads game
func load_game():
	if FileAccess.file_exists("user://save.sav"):
		var save_file: FileAccess = FileAccess.open("user://save.sav", FileAccess.READ)
		var save_text: String = save_file.get_as_text()
		if save_text.contains("{") && save_text.contains("}"):
			save_data = JSON.parse_string(save_text)

## Saves game
func save_game():
	save_data["map_seed"] = get_parent().map_seed_name
	save_data["location"] = get_parent().protagonist.global_position
	var save_file: FileAccess = FileAccess.open("user://save.sav", FileAccess.WRITE)
	save_file.store_line(JSON.stringify(save_data))

## Resets save (used after endings)
func reset_save():
	var save_file: FileAccess = FileAccess.open("user://save.sav", FileAccess.WRITE)
	save_file.store_line("")
