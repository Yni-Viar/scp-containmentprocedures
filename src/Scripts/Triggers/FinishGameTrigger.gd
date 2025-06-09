extends Area3D

var mtf_guarding: int = 0

func _on_body_entered(body: Node3D) -> void:
	if body is MovableNpc:
		if body.puppet_class.puppet_class_name == "SCP-347":
			if get_tree().get_node_count_in_group("MobileTaskForce") > 0 && mtf_guarding > 0:
				get_tree().root.get_node("Game/FoundationTask").do_task("task_347")
				body.queue_free()
				get_tree().root.get_node("Game").despawn_wave(0)
			else:
				get_tree().root.get_node("Game").finish_game(false, "GAME_OVER_2")
		elif body.fraction == 0 && body.puppet_class.team == 1:
			mtf_guarding += 1

func _on_body_exited(body: Node3D) -> void:
	if body is MovableNpc:
		if body.fraction == 0 && body.puppet_class.team == 1:
			mtf_guarding -= 1
