extends Area3D
## Switch camera mode to StaticPlayer.CameraMode (unused as of 6.0)
## Created by Yni, licensed under MIT License

@export var camera_mode: StaticPlayer.CameraMode

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node3D) -> void:
	if body is MovableNpc:
		if body.is_player:
			get_tree().root.get_node("Game/StaticPlayer").camera_mode = camera_mode


func _on_body_exited(body: Node3D) -> void:
	if body is MovableNpc:
		if body.is_player:get_tree().root.get_node("Game/StaticPlayer").camera_mode = StaticPlayer.CameraMode.ALL
			
