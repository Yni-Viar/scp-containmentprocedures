extends OpenableDoor
## Created by Yni, licensed under dual license: for SCP content - GPL 3, for non-SCP - MIT License

func _on_enter_trigger_body_entered(body: Node3D) -> void:
	super._on_enter_trigger_body_entered(body)
	if body is MovableNpc:
		if body.is_player && get_tree().root.get_node("Game/StoryModeNode").save_data["quest_progress"] == 6:
			get_tree().root.get_node("Game/FoundationTask").do_story_task()
