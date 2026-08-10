extends GPUParticles3D
## Made by Yni, licensed under CC0

# Called when the node enters the scene tree for the first time.
func _enter_tree() -> void:
	if OS.get_name() == "Web":
		emitting = false
