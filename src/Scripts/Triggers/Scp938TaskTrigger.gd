extends Area3D
## Created by Yni, licensed under dual license: for SCP content - GPL 3, for non-SCP - MIT License

var class_d_amount: int = 0
var foundation_amount: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if get_tree().root.get_node("Game/FoundationTask").has_task("task_938") && get_tree().get_node_count_in_group("DClassSpawn") == 0:
		get_tree().root.get_node("Game/FoundationTask").initialize()

func _on_body_entered(body: Node3D) -> void:
	if body is MovableNpc:
		if body.fraction == 0:
			match body.puppet_class.team:
				1:
					foundation_amount += 1
				2:
					class_d_amount += 1
		if class_d_amount >= 3 && foundation_amount >= 1:
			#Achievement
			if Settings.setting_res.scp_study_progress_full.has("SCP-938"):
				if !Settings.setting_res.scp_study_progress_full["SCP-938"]:
					Settings.setting_res.scp_study_progress_full["SCP-938"] = true
					Settings.save_resource(Settings.setting_res)
			get_tree().root.get_node("Game/FoundationTask").do_task("task_938")


func _on_body_exited(body: Node3D) -> void:
	if body is MovableNpc:
		if body.fraction == 0:
			match body.puppet_class.team:
				1:
					foundation_amount -= 1
				2:
					class_d_amount -= 1
