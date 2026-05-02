extends Area3D
## Switches environment
## Made by Yni, licensed under MIT License.

@export var env: Environment



func _on_body_entered(body: Node3D) -> void:
	if body is MovableNpc:
		if body.is_player:
			apply_environment(env)

func _on_body_exited(body: Node3D) -> void:
	if body is MovableNpc:
		if body.is_player:
			apply_environment(load("res://Assets/Environment/Default.tres"))

func apply_environment(environment: Environment):
	get_tree().root.get_node("Game/WorldEnvironment").environment = environment
	get_tree().root.get_node("Game/WorldEnvironment").environment.glow_enabled = Settings.setting_res.glow
	# Enable SSAO in OpenGL only in Godot 4.6
	if RenderingServer.get_current_rendering_method() == "forward_plus" || \
	 (RenderingServer.get_current_rendering_method() == "gl_compatibility" && \
	  Engine.get_version_info()["minor"] >= 6):
		get_tree().root.get_node("Game/WorldEnvironment").environment.ssao_enabled = Settings.setting_res.ssao
	get_tree().root.get_node("Game/WorldEnvironment").environment.tonemap_mode = Settings.setting_res.tonemapper
	if Settings.setting_res.tonemapper != Environment.TONE_MAPPER_LINEAR || \
	 Settings.setting_res.tonemapper != Environment.TONE_MAPPER_AGX:
		get_tree().root.get_node("Game/WorldEnvironment").environment.tonemap_white = 2.0
	else:
		get_tree().root.get_node("Game/WorldEnvironment").environment.tonemap_white = 1.0
