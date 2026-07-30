extends Scp347PuppetScript
## Created by Yni, licensed under dual license: for SCP content - GPL 3, for non-SCP - MIT License
class_name S_Scp347PuppetScript

var task_9_talk_finished: bool = false

func special_action():
	match get_tree().root.get_node("Game/StoryModeNode").save_data["quest_progress"]:
		3:
			get_tree().root.get_node("Game/UI/DialoguePanel/DialogueBox").start("dlg_347_scp")
			get_tree().root.get_node("Game/UI/DialoguePanel").show()
		9:
			if !task_9_talk_finished:
				get_tree().root.get_node("Game/UI/DialoguePanel/DialogueBox").start("dlg_347_sh")
				get_tree().root.get_node("Game/UI/DialoguePanel").show()
				var scp_347_gate: Node = get_tree().get_first_node_in_group("Scp347ShGate")
				if scp_347_gate is NavigationLink3D:
					scp_347_gate.enabled = true
				task_9_talk_finished = true
				get_parent().get_parent().follow_target = get_tree().root.get_node("Game/StaticPlayer").target_puppet_path
