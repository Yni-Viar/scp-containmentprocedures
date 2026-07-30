extends InteractableStatic
## Created by Yni, licensed under dual license: for SCP content - GPL 3, for non-SCP - MIT License


func interact(player: Node3D):
	if get_tree().root.get_node("Game/StoryModeNode").save_data["quest_progress"] == 7:
		get_tree().root.get_node("Game/UI/DialoguePanel/DialogueBox").start("dlg_where_is_181")
		get_tree().root.get_node("Game/UI/DialoguePanel").show()
		var scp_914_room: Node = get_tree().get_first_node_in_group("Scp914Room")
		if scp_914_room is S_Cont1_914:
			scp_914_room.story_trigger()
		
	super.interact(player)
