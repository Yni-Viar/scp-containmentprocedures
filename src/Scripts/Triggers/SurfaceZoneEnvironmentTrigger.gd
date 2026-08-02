extends EnvironmentTrigger

## Check if player is on Surface Zone
@export var entered_surface: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_body_entered(body: Node3D) -> void:
	if body is MovableNpc:
		if body.is_player:
			match OS.get_name():
				"Web":
					apply_environment(load("res://Assets/Environment/Outside_LQ.tres"))
				"Android":
					if OS.has_feature("Lite"):
						apply_environment(load("res://Assets/Environment/Outside_LQ.tres"))
					else:
						apply_environment(load("res://Assets/Environment/Outside_MQ_Default.tres"))
				_:
					apply_environment(load("res://Assets/Environment/Outside_HQ_Default.tres"))
			entered_surface = true

func _on_body_exited(body: Node3D) -> void:
	if body is MovableNpc:
		if body.is_player:
			apply_environment(load("res://Assets/Environment/Default.tres"), true)
			entered_surface = false
