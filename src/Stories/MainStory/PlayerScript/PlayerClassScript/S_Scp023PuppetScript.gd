extends Scp023PuppetScript


func on_spawned() -> void:
	if !get_tree().root.get_node("Game/StoryModeNode").save_data["scp_023"]:
		glow_enabled = false if get_tree().root.get_node("Game").rng.randi_range(0, 1) == 1 else true
	else:
		glow_enabled = false
	super.on_spawned()

func special_action():
	super.special_action()
	get_tree().root.get_node("Game/StoryModeNode").save_data["scp_023"] = true
