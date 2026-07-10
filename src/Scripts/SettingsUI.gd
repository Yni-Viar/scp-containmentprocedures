extends VBoxContainer
## Made by Yni, licensed under MIT License.

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Settings.feature_legality_checker("no_neural_ai"):
		$GameplayLabel.queue_free()
		$AI.queue_free()
	else:
		$AI.button_pressed = Settings.setting_res.ai_enabled
	$Renderer.selected = Settings.setting_res.renderer
	$Lighting.selected = Settings.setting_res.lighting
	$Glow.button_pressed = Settings.setting_res.glow
	$BasicReflection.button_pressed = Settings.setting_res.reflection_probe
	$SSAO.button_pressed = Settings.setting_res.ssao
	$Music/MusicVolume.value = Settings.setting_res.music_volume
	$Tonemapper.selected = Settings.setting_res.tonemapper
	if OS.get_name() == "Web":
		# Disable advanced tonemappers and non-WebGL renderers
		$Tonemapper.set_item_disabled(2, true)
		$Tonemapper.set_item_disabled(3, true)
		$Tonemapper.set_item_disabled(4, true)
		$Renderer.set_item_disabled(1, true)
		$Renderer.set_item_disabled(2, true)
		$Renderer.hide()
		$Label3.hide()
	elif OS.get_name() == "Android" || Engine.get_version_info()["minor"] == 7:
		# Disable Mobile and Forward+ renderers on Android and all of Godot 4.7.0.
		$Renderer.set_item_disabled(1, true)
		$Renderer.set_item_disabled(2, true)
		$Renderer.hide()
		$Label3.hide()
	
	if Settings.setting_res.renderer == SettingsResource.Renderer.OPENGL:
		# Disable real-time lighting op OpenGL
		if $Lighting.selected == 2:
			$Lighting.selected = 0
			_on_lighting_item_selected(0)
		$Lighting.set_item_disabled(2, true)
	elif Settings.setting_res.renderer == SettingsResource.Renderer.RD_FORWARD_PLUS:
		# Disable lightmap on all RD renderers (because of Godot limitation, see
		# https://github.com/godotengine/godot-proposals/issues/12577 for more information)
		if $Lighting.selected == 1:
			$Lighting.selected = 0
			_on_lighting_item_selected(0)
		$Lighting.set_item_disabled(1, true)
	else:
		if $Lighting.selected != 0:
			$Lighting.selected = 0
			_on_lighting_item_selected(0)
		$Lighting.set_item_disabled(1, true)
		# Also disable realtime lights for RD Mobile
		$Lighting.set_item_disabled(2, true)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass

func _on_music_volume_drag_ended(value_changed: bool) -> void:
	if value_changed:
		Settings.audio_settings(1, $Music/MusicVolume.value)
		Settings.setting_res.music_volume = $Music/MusicVolume.value
		Settings.save_resource(Settings.setting_res)

func _on_basic_reflection_toggled(toggled_on: bool) -> void:
	Settings.setting_res.reflection_probe = toggled_on
	Settings.save_resource(Settings.setting_res)

func _on_glow_toggled(toggled_on: bool) -> void:
	Settings.setting_res.glow = toggled_on
	Settings.save_resource(Settings.setting_res)

func _on_ssao_toggled(toggled_on: bool) -> void:
	Settings.setting_res.ssao = toggled_on
	Settings.save_resource(Settings.setting_res)


func _on_tonemapper_item_selected(index: int) -> void:
	Settings.setting_res.tonemapper = index as Environment.ToneMapper
	Settings.save_resource(Settings.setting_res)


func _on_ai_toggled(toggled_on: bool) -> void:
	Settings.setting_res.ai_enabled = toggled_on
	Settings.save_resource(Settings.setting_res)


func _on_renderer_item_selected(index: int) -> void:
	Settings.setting_res.renderer = index as SettingsResource.Renderer
	Settings.save_resource(Settings.setting_res)
	Settings.change_renderer()

func _on_lighting_item_selected(index: int) -> void:
	Settings.setting_res.lighting = index as SettingsResource.Lighting
	Settings.save_resource(Settings.setting_res)


func _on_settings_visibility_changed() -> void:
	if OS.get_name() == "Web" && Settings.beta_mode:
		$GameplayLabel.show()
		$AI.show()
