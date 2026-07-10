extends AttackerPuppetScript
## Chaos Insurgent Trooper puppet
## Created by Yni, licensed under dual license: for SCP content - GPL 3, for non-SCP - MIT License

## Follow player if see.
var saw_player: bool = false

# Called when the node enters the scene tree for the first time.
func on_start_human() -> void:
	go_to_target(get_tree().root.get_node("Game/StaticPlayer").target_puppet_path)


func on_update_human(delta: float):
	if !saw_player && raycast.is_colliding():
		var collider = raycast.get_collider()
		if collider is MovableNpc:
			var puppet_class = collider.puppet_class
			if puppet_class.fraction == 0 && puppet_class.team == 1:
				saw_player = true
				if !get_parent().get_parent().movement_freeze:
					get_parent().get_parent().follow_target = collider.get_path()
	elif state == States.IDLE:
		if timer > 0.0:
			timer -= delta
		else:
			go_to_target(get_tree().root.get_node("Game/StaticPlayer").target_puppet_path)
			timer = 10.0

func _on_raycast_update_npc(collider_path: String):
	var _collider_prefab: MovableNpc = get_node(collider_path)
	if _collider_prefab.puppet_class.fraction == 0 && _collider_prefab.puppet_class.team != 3:
		attack(collider_path)

func attack(collider_path: String):
	var test = get_node(collider_path)
	if test != null:
		test.health_manage(-70.0, 0, "GAME_OVER_CI")
	await get_tree().create_timer(0.375).timeout
