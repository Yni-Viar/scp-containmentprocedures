extends Area3D
## SCP-266 task trigger script
## Created by Yni, licensed under dual license: for SCP content - GPL 3, for non-SCP - MIT License


var counter_task: float = 0.0
var heat_cooldown: float = 1.0
var people: Array[MovableNpc]

func _physics_process(delta: float) -> void:
	if people.size() > 0:
		deplete_health(delta)
		counter_task += delta * 0.5 * people.size()
		if counter_task > 1.0:
			get_tree().root.get_node("Game/FoundationTask").do_task("task_266")
			set_process(false)
			set_physics_process(false)
			monitoring = false
			monitorable = false

func _on_body_entered(body: Node3D) -> void:
	if body is MovableNpc:
		if body.puppet_class.team > 2 && get_tree().get_node_count_in_group("DClassSpawn") > 0:
			people.append(body)
		elif body.fraction == 0:
			people.append(body)


func _on_body_exited(body: Node3D) -> void:
	if body is MovableNpc:
		if body.fraction == 0:
			people.erase(body)

func deplete_health(delta: float):
	if heat_cooldown > 0.0:
		heat_cooldown -= delta
	else:
		for human in people:
			human.health_manage(-1)
		heat_cooldown = 1.0
