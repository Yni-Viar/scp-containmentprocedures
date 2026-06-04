extends EnvironmentTrigger


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_body_entered(body: Node3D) -> void:
	if body is MovableNpc:
		if body.is_player:
			if OS.get_name() != "Web" && OS.get_name() != "Android":
				if Settings.current_season == Settings.Season.SPRING:
					apply_environment(load("res://Assets/Environment/Outside_HQ_Default.tres"))
				else:
					apply_environment(load("res://Assets/Environment/Outside_HQ_Rainy.tres"))
			else:
				apply_environment(load("res://Assets/Environment/Outside_LQ.tres"))
