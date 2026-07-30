extends Area3D
## Created by Yni, licensed under dual license: for SCP content - GPL 3, for non-SCP - MIT License

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node3D) -> void:
	if body is MovableNpc:
		if body.is_player && get_tree().root.get_node("Game/StoryModeNode").save_data["quest_progress"] == 1:
			get_tree().root.get_node("Game/UI/DialoguePanel/DialogueBox").start("dlg_key_not_found")
			get_tree().root.get_node("Game/UI/DialoguePanel").show()
