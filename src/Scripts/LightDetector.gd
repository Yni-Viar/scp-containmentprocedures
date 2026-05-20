extends SubViewport
## Light detector, used for environment lighting without ReflectionProbes.

@export var enabled: bool = false
var time_to_update: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Settings.setting_res.reflection_probe || Settings.setting_res.lighting == SettingsResource.Lighting.NONE:
		$LightDetector.current = false
		set_process(false)
	else:
		enabled = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if enabled:
		if time_to_update > 0.0:
			time_to_update -= delta
		else:
			
			render_target_update_mode = SubViewport.UPDATE_ALWAYS
			call_deferred("pause_rendering")
			time_to_update = 8.0 if OS.get_name() in ["Web", "Android"] else 4.0
	$LightDetector.global_position = get_parent().global_position

func pause_rendering():
	var color: float = await light_detect()
	get_tree().root.get_viewport().world_3d.environment.background_color = Color(color, color, color)
	render_target_update_mode = SubViewport.UPDATE_DISABLED

func light_detect() -> float:
	await RenderingServer.frame_post_draw
	var texture: Image = self.get_texture().get_image()
	texture.resize(1, 1, Image.INTERPOLATE_LANCZOS)
	var color: Color = texture.get_pixel(0, 0)
	return color.get_luminance()
