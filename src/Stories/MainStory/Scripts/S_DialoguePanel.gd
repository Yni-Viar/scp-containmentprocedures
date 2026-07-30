extends Control
## Created by Yni, licensed under dual license: for SCP content - GPL 3, for non-SCP - MIT License

var next_background: Texture2D = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_dialogue_box_dialogue_signal(value: String) -> void:
	match value:
		"next_task":
			get_tree().root.get_node("Game/FoundationTask").do_story_task()
		"end_game":
			get_tree().root.get_node("Game").complete_game()


func _on_dialogue_box_variable_changed(variable_name: String, value: Variant) -> void:
	match variable_name:
		"background":
			if value is String:
				if value.is_empty() || value == "empty":
					next_background = null
				else:
					next_background = load(value)
				$AnimationPlayer.play("change_background")
		"scp":
			if value is int:
				get_tree().root.get_node("Game/StoryModeNode").save_data["scp"] = value

func _change_background() -> void:
	$Background.texture = next_background


func _on_dialogue_box_dialogue_ended() -> void:
	next_background = null
	$AnimationPlayer.play("change_background")
	await get_tree().create_timer(2.0).timeout
	hide()
