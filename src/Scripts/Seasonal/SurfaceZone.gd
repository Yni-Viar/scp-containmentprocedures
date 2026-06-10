extends StaticBody3D
## Made by Yni, licensed under MIT License.
class_name SurfaceZone

@export var current_season: Settings.Season

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Settings.current_season == 5:
		var material: ShaderMaterial = load("res://Shaders/SnowShader/snow.tres")
		if get_node_or_null("NavigationRegion3D/Cube_030") != null:
			$NavigationRegion3D/Cube_030.set_surface_override_material(1, material)
			$NavigationRegion3D/Cube_030.set_surface_override_material(2, material)
		if get_node_or_null("NavigationRegion3D/Plane_001") != null:
			$NavigationRegion3D/Plane_001.set_surface_override_material(0, material)
		if get_node_or_null("NavigationRegion3D/Trimming2MiddlePieceCornerInner_003") != null:
			$NavigationRegion3D/Trimming2MiddlePieceCornerInner_003.set_surface_override_material(1, material)
			$NavigationRegion3D/Trimming2MiddlePieceCornerInner_003.set_surface_override_material(2, material)
			$NavigationRegion3D/Trimming2MiddlePieceCornerInner_003.set_surface_override_material(4, material)
			$NavigationRegion3D/Trimming2MiddlePieceCornerInner_003.set_surface_override_material(5, material)
			$NavigationRegion3D/Trimming2MiddlePieceCornerInner_003.set_surface_override_material(13, material)
			$NavigationRegion3D/Trimming2MiddlePieceCornerInner_003.set_surface_override_material(14, material)
