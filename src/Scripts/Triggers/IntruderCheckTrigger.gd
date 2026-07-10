extends Area3D
## Checks if 347 is escaping and detects CI invasion.
## Made by Yni, licensed under MIT License.

@export var detect_scp347: bool = true
@export var detect_CI:bool = true

func _on_body_entered(body: Node3D) -> void:
	if body is MovableNpc:
		if body.puppet_class.puppet_class_name == "SCP-347" && detect_scp347:
			body.get_node("PlayerModel").get_child(0).infrared_visibility = true
		if body.fraction == 0 && body.puppet_class.team == 3 && detect_CI:
			if !get_tree().root.get_node("Game/FoundationTask").has_task("task_ci"):
				get_tree().root.get_node("Game/FoundationTask").trigger_event(3, load("res://Scripts/TaskSystem/Tasks/CIEmergencyTask.tres"))
				get_tree().root.get_node("Game/UI/HBoxContainer/CallMtfButton").show()


func _on_body_exited(body: Node3D) -> void:
	if body is MovableNpc:
		if body.puppet_class.puppet_class_name == "SCP-347" && detect_scp347:
			body.get_node("PlayerModel").get_child(0).infrared_visibility = false
