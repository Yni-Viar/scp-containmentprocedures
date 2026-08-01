extends Node
## Save system
## Created by Yni, licensed under dual license: for SCP content - GPL 3, for non-SCP - MIT License

@export var save_data: Dictionary = {
	"map_seed": "",
	"location": Vector3.ZERO,
	"quest_progress": 0,
	"scp": 10,
	"current_day": 0,
	"scp_023": false,
	"hour": 8
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

## Loads game
func load_game() -> bool:
	if FileAccess.file_exists("user://save.sav"):
		var save_file: FileAccess = FileAccess.open("user://save.sav", FileAccess.READ)
		var save_text: String = save_file.get_as_text()
		if save_text.begins_with("{"):
			var save: Dictionary = JSON.to_native(JSON.parse_string(save_text))
			if validate_save(save):
				save["quest_progress"] = int(save["quest_progress"])
				save["scp"] = int(save["scp"])
				save["current_day"] = int(save["current_day"])
				save["hour"] = int(save["hour"])
				save_data = save
				save_file.close()
				return true
		save_file.close()
	return false

## Saves game
func save_game():
	save_data["map_seed"] = get_parent().map_seed_name
	save_data["location"] = get_parent().protagonist.global_position
	save_data["hour"] = get_parent().hours
	var save_file: FileAccess = FileAccess.open("user://save.sav", FileAccess.WRITE)
	save_file.store_line(JSON.stringify(JSON.from_native(save_data)))
	save_file.close()

## Resets save (used after endings)
func reset_save():
	var save_file: FileAccess = FileAccess.open("user://save.sav", FileAccess.WRITE)
	save_file.store_line("")
	save_file.close()

func validate_save(save: Dictionary) -> bool:
	if save.has("map_seed") && \
	   save.has("location") && \
	   save.has("quest_progress") && \
	   save.has("scp") && \
	   save.has("current_day") && \
	   save.has("scp_023") && \
	   save.has("hour"):
		if save["map_seed"] is String && \
		   save["location"] is Vector3 && \
		   save["quest_progress"] is int && \
		   save["scp"] is int && \
		   save["current_day"] is int && \
		   save["scp_023"] is bool && \
		   save["hour"] is int:
			return true
	return false
