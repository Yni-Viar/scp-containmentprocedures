extends HumanPuppetScript


## If the player is near, attack
var near_targets: bool = false
## Follow player if see.
var saw_player: bool = false
## Attack timer
var attack_update_timer: float = 2.0

# Called when the node enters the scene tree for the first time.
#func on_start_human() -> void:
	# Retrieve protagonist node path and make it follow target
	#get_parent().get_parent().follow_target = get_tree().get_first_node_in_group("MainCharacter").get_parent().get_parent().get_parent().get_path()


func on_update_human(delta: float):
	if near_targets:
		attack()
	elif get_tree().get_node_count_in_group("ChaosInsurgency") > 0:
		var collider = get_tree().get_nodes_in_group("ChaosInsurgency")[get_tree().get_node_count_in_group("ChaosInsurgency") - 1]
		if collider is MovableNpc:
			var puppet_class = collider.puppet_class
			if puppet_class.fraction == 0 && puppet_class.team == 3:
				if !get_parent().get_parent().movement_freeze:
					get_parent().get_parent().follow_target = collider.get_path()
	elif get_tree().get_node_count_in_group("ChaosInsurgency") == 0 && get_tree().root.get_node("Game/FoundationTask").has_task("task_ci"):
		get_tree().root.get_node("Game/FoundationTask").trigger_event(0)


func _on_attack_radius_body_entered(body: Node3D) -> void:
	if body is MovableNpc:
		if str(body.get_path()) == get_parent().get_parent().follow_target:
			near_targets = true
		#else:
			#var puppet_class = body.puppet_class
			#if puppet_class.fraction == 0 && puppet_class.team == 3:
				#near_targets = true
				#if !get_parent().get_parent().movement_freeze:
					#get_parent().get_parent().follow_target = body.get_path()


func _on_attack_radius_body_exited(body: Node3D) -> void:
	if body is MovableNpc:
		if str(body.get_path()) == get_parent().get_parent().follow_target || get_parent().get_parent().movement_freeze:
			near_targets = false

func attack():
	if attack_update_timer > 0:
		attack_update_timer -= get_physics_process_delta_time()
	else:
		secondary_state = SecondaryState.JAILBIRD_ATTACK
		var test = get_parent().get_parent().follow_target
		get_node(test).health_manage(-40.0)
		attack_update_timer = 2.0
