extends EnvironmentTrigger

## Check if player is on Surface Zone
@export var entered_surface: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _on_body_entered(body: Node3D) -> void:
	if body is MovableNpc:
		if body.is_player:
			if Settings.setting_res.enable_advanced_sky:
				apply_environment(load("res://Assets/Environment/Outside_HQ.tres"))
			else:
				apply_environment(load("res://Assets/Environment/Outside_LQ.tres"))
			get_tree().root.get_node("Game/StaticPlayer/Head/Camera3D").far = 160.0
			entered_surface = true

func _on_body_exited(body: Node3D) -> void:
	if body is MovableNpc:
		if body.is_player:
			apply_environment(load("res://Assets/Environment/Default.tres"), true)
			get_tree().root.get_node("Game/StaticPlayer/Head/Camera3D").far = 60.0
			entered_surface = false
