extends StaticBody3D
## Base script for Surface Zone snow and story_mode round
## Made by Yni, licensed under MIT License.
class_name SurfaceZone

@export var current_season: Settings.Season
@export var daytime_change: bool = false

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

func _physics_process(delta: float) -> void:
	$DirectionalLight3D.rotation.x += (PI / 180) * delta
	if ($DirectionalLight3D.rotation_degrees.x > -180.0 && $DirectionalLight3D.rotation_degrees.x < 0.0) || ($DirectionalLight3D.rotation_degrees.x > 180.0 && $DirectionalLight3D.rotation_degrees.x < 360.0):
		if $SwitchEnvironmentTrigger.entered_surface:
			if !$DirectionalLight3D.visible:
				$DirectionalLight3D.show()
		else:
			$DirectionalLight3D.hide()
	else:
		if $DirectionalLight3D.visible:
			$DirectionalLight3D.hide()
	
	get_tree().root.get_node("Game").hours = wrap($DirectionalLight3D.rotation_degrees.x / 15.0 - 6, 0, 24)

func set_time(hours: int, minutes: int):
	$DirectionalLight3D.rotation.x = deg_to_rad(15.0 * (hours + 6) + minutes / 60.0 * 15.0)
