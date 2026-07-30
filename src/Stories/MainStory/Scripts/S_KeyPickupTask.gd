extends Area3D
## Created by Yni, licensed under dual license: for SCP content - GPL 3, for non-SCP - MIT License


func _on_body_entered(body: Node3D) -> void:
	if body is MovableNpc:
		if body.is_player && body.keycards.has(-2584) && get_tree().root.get_node("Game/StoryModeNode").save_data["quest_progress"] == 5:
			get_tree().root.get_node("Game/FoundationTask").do_story_task()
