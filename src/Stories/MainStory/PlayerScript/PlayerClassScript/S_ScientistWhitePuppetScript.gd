extends SkinnableHumanPuppetScript
## Created by Yni, licensed under dual license: for SCP content - GPL 3, for non-SCP - MIT License
class_name S_ScientistWhitePuppetScript

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
