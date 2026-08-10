extends RoomPrefab
## Created by Yni, licensed under dual license: for SCP content - GPL 3, for non-SCP - MIT License
class_name S_Cont1_914

func _ready() -> void:
	if get_tree().root.get_node("Game/StoryModeNode").save_data["scp_914_cutscene"] > 0:
		story_trigger()

func story_trigger() -> void:
	var npc: MovableNpc = load("res://PlayerScript/NPCBase.tscn").instantiate()
	npc.puppet_class = load("res://Stories/MainStory/PlayerScript/PlayerClassResources/Scp181.tres")
	$Scp181Spawn.add_child(npc)
	if get_tree().root.get_node("Game/StoryModeNode").save_data["scp_914_cutscene"] == 0:
		get_tree().root.get_node("Game/StoryModeNode").save_data["scp_914_cutscene"] = 1


func _on_story_trigger_body_entered(body: Node3D) -> void:
	if body is MovableNpc:
		if body.is_player && get_tree().root.get_node("Game/StoryModeNode").save_data["quest_progress"] == 8:
			get_tree().root.get_node("Game/UI/DialoguePanel/DialogueBox").start("dlg_there_is_181")
			get_tree().root.get_node("Game/UI/DialoguePanel").show()
			get_node(get_tree().root.get_node("Game/StaticPlayer").target_puppet_path + "/UI/Inventory").hide()
			await get_tree().create_timer(2.0).timeout
			var dr_white: Node = get_tree().get_first_node_in_group("ScientistWhite")
			if dr_white is S_ScientistWhitePuppetScript:
				dr_white.get_parent().get_parent().global_position = $DrWhiteSpawn.global_position
				if get_tree().root.get_node("Game/StoryModeNode").save_data["scp_914_cutscene"] == 1:
					get_tree().root.get_node("Game/StoryModeNode").save_data["scp_914_cutscene"] = 2
