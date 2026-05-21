extends Area3D
## SCP-266 task trigger script
## Created by Yni, licensed under dual license: for SCP content - GPL 3, for non-SCP - MIT License


var counter_task: float = 0.0
var people: Array[MovableNpc]
var d_class_came: bool = false

func _physics_process(delta: float) -> void:
	if people.size() > 0 && d_class_came:
		counter_task += delta * 0.5 * people.size()
		if counter_task > 1.0:
			get_tree().root.get_node("Game/FoundationTask").do_task("task_266")
			set_process(false)
			set_physics_process(false)
			monitoring = false
			monitorable = false

func _on_body_entered(body: Node3D) -> void:
	if body is MovableNpc:
		if body.puppet_class.fraction == 0:
			if body.puppet_class.team >= 2:
				d_class_came = true
			people.append(body)


func _on_body_exited(body: Node3D) -> void:
	if body is MovableNpc:
		if body.puppet_class.fraction == 0:
			if body.puppet_class.team >= 2:
				d_class_came = false
			people.erase(body)
