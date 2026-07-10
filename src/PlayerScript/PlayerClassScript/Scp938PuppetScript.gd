extends BasePuppetScript
## SCP-938 puppet script
## Created by Yni, licensed under dual license: for SCP content - GPL 3, for non-SCP - MIT License
class_name Scp938PuppetScript

enum Scp938State{DORMANT = 0, ACTIVE_WANDERING = 1, ACTIVE_ATTACKING = 2}

var current_state: Scp938State = Scp938State.DORMANT:
	set(val):
		current_state = val
		if current_state != Scp938State.DORMANT:
			if get_tree().root.get_node_or_null("Game/StoryModeNode") != null:
				get_tree().root.get_node("Game").finish_game(false, "GAME_OVER_SCP_938")
			teleport_is_ready = true
var timer: float = 24.0
var teleport_is_ready: bool = false
# Favourite SCP-938 target
var favourite_target: MovableNpc

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	favourite_target = get_tree().get_nodes_in_group("Players").pick_random()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if current_state != 0:
		if timer > 0:
			timer -= delta
		else:
			teleport_is_ready = true
			timer = 8.0
	# What SCP-938 do if breached.
	match current_state:
		1:
			if !get_parent().get_parent().wandering:
				get_parent().get_parent().wandering_system = MovableNpc.WanderingSystem.GENERIC_WANDER
			if teleport_is_ready:
				get_parent().get_parent().global_position = NavigationServer3D.map_get_random_point(get_parent().get_parent().get_node("NavigationAgent3D").get_navigation_map(), 1, true)
				teleport_is_ready = false
		2:
			if teleport_is_ready:
				teleport_is_ready = false
				get_parent().get_parent().wandering_system = MovableNpc.WanderingSystem.NONE
				# Electrocute favourite target
				if favourite_target != null:
					get_parent().get_parent().global_position = favourite_target.global_position - favourite_target.global_transform.basis.z * 2
			else:
				current_state = 1 as Scp938State

func _on_attack_area_body_entered(body: Node3D) -> void:
	if body is MovableNpc:
		if body.puppet_class.puppet_class_name != "SCP-938" && !body.platform_moving:
			body.get_node("StatusEffects").apply_status_effect("Electrocuted", 1.0, 1.0)
			body.health_manage(-80, 0, "GAME_OVER_SCP_938")
			await get_tree().create_timer(2.0).timeout
			if body != null:
				favourite_target = body
			else:
				favourite_target = get_tree().get_nodes_in_group("Players").pick_random()
			current_state = rng.randi_range(1, 2)
