extends Node3D
## Made by Yni, licensed under MIT License.

var rng: RandomNumberGenerator

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Settings.current_season == Settings.Season.CHRISTMAS:
		#set random color
		rng = get_tree().root.get_node("Game").rng
		if get_node_or_null("Cylinder_001") != null:
			var mat: ShaderMaterial = $Cylinder_001.mesh.surface_get_material(1)
			mat.set_shader_parameter("emission", Color(rng.randf_range(0.5, 1.0), rng.randf_range(0.5, 1.0), rng.randf_range(0.5, 1.0)))
			$Cylinder_001.mesh.surface_set_material(1, mat)
