extends RoomPrefab
## SCP-080
## Created by Yni, licensed under dual license: for SCP content - GPL 3, for non-SCP - MIT License
class_name Scp080RoomPrefab

@export_group("Do not touch - automatic")
## Structure {
## path: {
##	"enabled": bool,
##	"power": float
##	}
@export var fatigue_targets: Dictionary[String, Dictionary] = {}
## SCP-080 source
@export var scp080: Scp080PuppetScript
var timer: float = 0

## Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#pass # Replace with function body.
#

func _on_fatigue_effect_body_entered(body: Node3D) -> void:
	if body is MovableNpc:
		if body.puppet_class.puppet_class_name == "SCP-080" && body.get_node_or_null("PlayerModel/Puppet/Scp080TouchTrigger") != null:
			scp080 = body.get_node("PlayerModel/Puppet")
			scp080.get_node("Scp080TouchTrigger").connect("body_entered", _on_scp080_body_entered)
		elif body.get_node_or_null("StatusEffects") != null && body.puppet_class.fraction == 0:
			fatigue_targets[str(body.get_path())] = {"enabled": true, "power": 0.03125}


func _on_fatigue_effect_body_exited(body: Node3D) -> void:
	if body is MovableNpc:
		if body.puppet_class.puppet_class_name == "SCP-080" && body.get_node_or_null("PlayerModel/Puppet/Scp080TouchTrigger") != null:
			scp080.get_node("Scp080TouchTrigger").disconnect("body_entered", _on_scp080_body_entered)
			scp080 = null
		elif body.get_node_or_null("StatusEffects") != null && body.puppet_class.fraction == 0 && fatigue_targets.has(str(body.get_path())):
			fatigue_targets[str(body.get_path())]["enabled"] = false

## Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	timer += delta
	if timer > 2.0:
		for target in fatigue_targets:
			if get_node_or_null(target) == null:
				fatigue_targets.erase(target)
				continue
			elif get_node(target) is not MovableNpc:
				fatigue_targets.erase(target)
				continue
			if Settings.setting_res.scp_study_progress_full.has("SCP-080"):
				if !Settings.setting_res.scp_study_progress_full["SCP-080"]:
					Settings.setting_res.scp_study_progress_full["SCP-080"] = true
					Settings.save_resource(Settings.setting_res)
			if get_tree().root.get_node("Game/FoundationTask").has_task("task_080") && get_node(target).puppet_class.fraction == 0 && get_node(target).puppet_class.team == 2:
				get_tree().root.get_node("Game/FoundationTask").do_task("task_080")
			if fatigue_targets[target]["enabled"]:
				fatigue_targets[target]["power"] += 0.03125
				get_node(target).get_node("StatusEffects").apply_status_effect("Fatigue", fatigue_targets[target]["power"], 0.0)
			else:
				fatigue_targets[target]["power"] -= 0.03125
				if fatigue_targets[target]["power"] < 0.3125:
					get_node(target).get_node("StatusEffects").apply_status_effect("Fatigue", 0.0, 0.0)
					fatigue_targets.erase(target)
					continue
		timer = 0.0

func _on_scp080_body_entered(body: Node3D) -> void:
	if fatigue_targets.has(str(body.get_path())):
		if fatigue_targets[str(body.get_path())]["power"] > 0.5:
			body.get_node("StatusEffects").apply_status_effect("Fatigue", 1.0, 0.0)
