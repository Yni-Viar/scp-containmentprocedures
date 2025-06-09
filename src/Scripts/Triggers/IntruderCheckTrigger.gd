extends Area3D



func _on_body_entered(body: Node3D) -> void:
	if body is MovableNpc:
		if body.puppet_class.puppet_class_name == "SCP-347":
			body.get_node("PlayerModel").get_child(0).infrared_visibility = true
			if get_tree().get_node_count_in_group("MobileTaskForce") == 0 || get_parent().get_node("FinishGame").mtf_guarding == 0:
				get_tree().root.get_node("Game/FoundationTask").trigger_event(2, load("res://Scripts/TaskSystem/Tasks/Scp347EmergencyTask.tres"))


func _on_body_exited(body: Node3D) -> void:
	if body is MovableNpc:
		if body.puppet_class.puppet_class_name == "SCP-347":
			body.get_node("PlayerModel").get_child(0).infrared_visibility = false
			if get_tree().get_node_count_in_group("MobileTaskForce") == 0 || get_parent().get_node("FinishGame").mtf_guarding == 0:
				get_tree().root.get_node("Game/FoundationTask").trigger_event(0)
