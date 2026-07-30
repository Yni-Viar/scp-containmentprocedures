extends IntruderCheckTrigger
## Created by Yni, licensed under dual license: for SCP content - GPL 3, for non-SCP - MIT License

func _on_body_entered(body: Node3D) -> void:
	if body is MovableNpc:
		if body.is_player && get_tree().root.get_node("Game/StoryModeNode").save_data["quest_progress"] == 10 && \
		   get_tree().root.get_node("Game/StoryModeNode").save_data["scp"] == 0:
			get_tree().root.get_node("Game").complete_game()
