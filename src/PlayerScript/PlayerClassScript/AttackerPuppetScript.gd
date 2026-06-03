extends SkinnableHumanPuppetScript
## Chaos and MTF base scripts
## Created by Yni, licensed under dual license: for SCP content - GPL 3, for non-SCP - MIT License
class_name AttackerPuppetScript

var timer: float = 10.0

## Smart target determination (only effective in facility and Surface Zone, cannot go to other sublevels)
func go_to_target(primary_target: String):
	if get_parent().get_parent().platform_moving:
		return
	get_parent().get_parent().follow_target = primary_target
	await get_tree().create_timer(0.5).timeout
	if !get_parent().get_parent().get_node("NavigationAgent3D").is_target_reachable():
		get_parent().get_parent().follow_target = get_tree().get_nodes_in_group("WavePointUpper")[rng.randi_range(0, get_tree().get_node_count_in_group("WavePointUpper") - 1)].get_path()
		if !get_parent().get_parent().get_node("NavigationAgent3D").is_target_reachable():
			get_parent().get_parent().follow_target = get_tree().get_nodes_in_group("WavePointLower")[rng.randi_range(0, get_tree().get_node_count_in_group("WavePointLower") - 1)].get_path()
