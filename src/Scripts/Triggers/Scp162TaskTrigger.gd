extends Area3D
## SCP-162 task trigger script
## Created by Yni, licensed under dual license: for SCP content - GPL 3, for non-SCP - MIT License

var player_came: bool = false
var counter_task: float = 0.0
var class_d_entered: bool = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if player_came && class_d_entered:
		counter_task += delta
		if counter_task > 1.0:
			get_tree().root.get_node("Game/FoundationTask").do_task("task_162")
			set_process(false)
			set_physics_process(false)
			monitoring = false
			monitorable = false


func _on_body_exited(body: Node3D) -> void:
	if body is MovableNpc:
		if body.fraction == 0 && body.puppet_class.team == 2:
			class_d_entered = false


func _on_scp_162_outer_space_body_entered(body: Node3D) -> void:
	if body is MovableNpc:
		if body.is_player:
			player_came = true


func _on_scp_162_outer_space_body_exited(body: Node3D) -> void:
	if body is MovableNpc:
		if body.is_player:
			player_came = false


func _on_body_entered(body: Node3D) -> void:
	if body is MovableNpc:
		if body.fraction == 0:
			if body.puppet_class.team == 2:
				class_d_entered = true
			if body.puppet_class.team != 1:
				body.follow_target = get_parent().get_node("Waypoint").get_path()
