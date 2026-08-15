extends SkinnablePuppetScript
## SCP-737 puppet script
## Created by Yni, licensed under dual license: for SCP content - GPL 3, for non-SCP - MIT License

@export var unlocked: bool = false
var attacking: bool = false

## Attack timer
var attack_update_timer: float = 0.0

var current_target: Node3D

# Called when the node enters the scene tree for the first time.
func on_spawned() -> void:
	plugin_api_function("start")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	plugin_api_function("update")

func special_action():
	plugin_api_function("special_action")
	if get_tree().root.get_node_or_null("Game/StoryModeNode") != null:
		get_tree().root.get_node("Game").finish_game(false, "GAME_OVER_SCP_737_BREACH")
	if active_puppets.size() == 0:
		get_parent().get_parent().wandering_system = MovableNpc.WanderingSystem.GENERIC_WANDER
	else:
		get_parent().get_parent().follow_target = active_puppets[0].get_path()
		get_parent().get_parent().wandering_system = MovableNpc.WanderingSystem.NONE

func attack():
	if attack_update_timer > 0:
		attack_update_timer -= get_physics_process_delta_time()
	else:
		current_target = get_node(get_parent().get_parent().follow_target)
		if current_target != null:
			plugin_api_function("attack")
			current_target.health_manage(-25.0, 0, "GAME_OVER_SCP_737")
			active_puppets.erase(current_target)
			current_target = null
			if active_puppets.size() > 0:
				get_parent().get_parent().follow_target = active_puppets[0].get_path()
			else:
				get_parent().get_parent().follow_target = ""
				get_parent().get_parent().wandering_system = MovableNpc.WanderingSystem.GENERIC_WANDER
		attack_update_timer = 2.0

func _on_active_puppets_changed() -> void:
	if unlocked:
		if active_puppets.size() == 0:
			get_parent().get_parent().follow_target = ""
			get_parent().get_parent().wandering_system = MovableNpc.WanderingSystem.GENERIC_WANDER
		else:
			plugin_api_function("near_trigger_changed")
			#Achievement
			if Settings.setting_res.scp_study_progress_all.has("SCP-737"):
				if !Settings.setting_res.scp_study_progress_all["SCP-737"]:
					Settings.setting_res.scp_study_progress_all["SCP-737"] = true
					Settings.save_resource(Settings.setting_res)
			get_parent().get_parent().follow_target = active_puppets[0].get_path()
			get_parent().get_parent().wandering_system = MovableNpc.WanderingSystem.NONE


func _on_attack_body_entered(body: Node3D) -> void:
	if unlocked && body is MovableNpc:
		if active_puppets.has(body) && body.puppet_class.fraction == 0 && body.puppet_class.team < 2048:
			attacking = true


func _on_attack_body_exited(body: Node3D) -> void:
	if unlocked && body is MovableNpc:
		if active_puppets.has(body) && body.puppet_class.fraction == 0 && body.puppet_class.team < 2048:
			attacking = false
