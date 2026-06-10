extends InteractableStatic

var rng: RandomNumberGenerator = RandomNumberGenerator.new()

## Teleport to random place, or into Yni basement, if went with SCP-005.
func interact(player: Node3D):
	super.interact(player)
	if player is MovableNpc && global_position.distance_to(player.global_position) < 3.0:
		#Achievement
		if Settings.setting_res.scp_study_progress_all.has("SCP-249"):
			if !Settings.setting_res.scp_study_progress_all["SCP-249"]:
				Settings.setting_res.scp_study_progress_all["SCP-249"] = true
				Settings.save_resource(Settings.setting_res)
		
		if player.get_node("PlayerModel").get_child_count() > 0:
			var puppet: BasePuppetScript = player.get_node("PlayerModel").get_child(0)
			if puppet is SkinnableHumanPuppetScript:
				if puppet.current_item == 15 || puppet.current_item == 18:
					#Achievement
					if Settings.setting_res.scp_study_progress_all.has("SCP-005"):
						if !Settings.setting_res.scp_study_progress_all["SCP-005"]:
							Settings.setting_res.scp_study_progress_all["SCP-005"] = true
							Settings.save_resource(Settings.setting_res)
					player.global_position = get_tree().root.get_node("Game/PD_basement/spawnpoint").global_position
					return
		
		player.global_position = get_tree().get_nodes_in_group("Door")[rng.randi_range(0, get_tree().get_node_count_in_group("Door") - 1)].global_position
		if get_tree().root.get_node("Game/FoundationTask").has_task("task_249"):
			get_tree().root.get_node("Game/FoundationTask").do_task("task_249")
	
