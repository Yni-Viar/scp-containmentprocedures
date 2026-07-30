extends SkinnableHumanPuppetScript

func special_action():
	if get_tree().root.get_node("Game/StoryModeNode").save_data["quest_progress"] == 2:
		get_tree().root.get_node("Game/UI/DialoguePanel/DialogueBox").start("dlg_classd")
		get_tree().root.get_node("Game/UI/DialoguePanel").show()
