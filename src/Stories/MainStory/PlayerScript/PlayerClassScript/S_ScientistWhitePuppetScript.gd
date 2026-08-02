extends SkinnableHumanPuppetScript
## Created by Yni, licensed under dual license: for SCP content - GPL 3, for non-SCP - MIT License
class_name S_ScientistWhitePuppetScript

func on_start_human() -> void:
	super.on_start_human()
	if get_tree().root.get_node("Game/StoryModeNode").save_data["quest_progress"] == 5:
		var omega_keycard: InteractableKey = load("res://Stories/MainStory/InventorySystem/Keys/omega_keycard.tscn").instantiate()
		get_tree().get_first_node_in_group("Scp173Key").add_child(omega_keycard)
	
	if get_tree().root.get_node("Game/StoryModeNode").save_data["scp_914_cutscene"] > 1:
		var scp_914_room: Node = get_tree().get_first_node_in_group("Scp914Room")
		if scp_914_room is S_Cont1_914:
			get_parent().get_parent().global_position = scp_914_room.get_node("DrWhiteSpawn").global_position
	await get_tree().physics_frame
	if get_tree().root.get_node("Game/StoryModeNode").save_data["scp_914_cutscene"] > 2:
		get_parent().get_parent().follow_target = get_tree().root.get_node("Game/StaticPlayer").target_puppet_path

func special_action():
	match get_tree().root.get_node("Game/StoryModeNode").save_data["quest_progress"]:
		4:
			get_tree().root.get_node("Game/UI/DialoguePanel/DialogueBox").start("dlg_white_scp")
			get_tree().root.get_node("Game/UI/DialoguePanel").show()
			var omega_keycard: InteractableKey = load("res://Stories/MainStory/InventorySystem/Keys/omega_keycard.tscn").instantiate()
			get_tree().get_first_node_in_group("Scp173Key").add_child(omega_keycard)
		9:
			var scp_347: Node = get_tree().get_first_node_in_group("Scp347")
			if scp_347 is S_Scp347PuppetScript:
				if scp_347.get_parent().get_parent().follow_target == get_tree().root.get_node("Game/StaticPlayer").target_puppet_path:
					get_tree().root.get_node("Game/UI/DialoguePanel/DialogueBox").start("dlg_final_sh")
					get_tree().root.get_node("Game/UI/DialoguePanel").show()
					get_parent().get_parent().follow_target = get_tree().root.get_node("Game/StaticPlayer").target_puppet_path
					if get_tree().root.get_node("Game/StoryModeNode").save_data["scp_914_cutscene"] == 2:
						get_tree().root.get_node("Game/StoryModeNode").save_data["scp_914_cutscene"] = 3
