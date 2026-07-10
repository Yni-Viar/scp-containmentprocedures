extends Pickable
## SCP-018
## Created by Yni, licensed under dual license: for SCP content - GPL 3, for non-SCP - MIT License
class_name Scp018

## Is SCP-018 activated. Disabled only in containment cube.
@export var activated: bool = false:
	set(val):
		activated = val
		if activated:
			#Achievement
			if Settings.setting_res.scp_study_progress_all.has("SCP-018"):
				if !Settings.setting_res.scp_study_progress_all["SCP-018"]:
					Settings.setting_res.scp_study_progress_all["SCP-018"] = true
					Settings.save_resource(Settings.setting_res)
## Impulse setter variable
@export var vel: Vector3 = Vector3.ZERO
## Speed coefficient
@export var coefficient: int = 1


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if activated:
		vel = get_tree().root.get_node("Game").protagonist.global_position.direction_to(get_tree().root.get_node("Game").protagonist.global_transform.basis.z * 2)


func _on_body_entered(body: Node) -> void:
	if activated:
		if coefficient < 16:
			coefficient *= 2
		if coefficient > 4 && get_tree().root.get_node_or_null("Game/StoryModeNode") != null:
			get_tree().root.get_node("Game").finish_game(false, "GAME_OVER_SCP_018_BREACH")
		apply_impulse(vel * coefficient)
		vel = global_position.direction_to(global_transform.basis.z * 2)


func _on_damage_trigger_body_entered(body: Node3D) -> void:
	if body is MovableNpc:
		if coefficient >= 8:
			body.health_manage(-5 * coefficient, 0, "GAME_OVER_SCP_018")
