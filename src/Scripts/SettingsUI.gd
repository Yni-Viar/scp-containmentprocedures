extends VBoxContainer
## Made by Yni, licensed under MIT License.

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Settings.feature_legality_checker("no_neural_ai"):
		$GameplayLabel.queue_free()
		$AI.queue_free()
	else:
		$AI.button_pressed = Settings.setting_res.ai_enabled
	$Glow.button_pressed = Settings.setting_res.glow
	$BasicReflection.button_pressed = Settings.setting_res.reflection_probe
	$SSAO.button_pressed = Settings.setting_res.ssao
	$Music/MusicVolume.value = Settings.setting_res.music_volume
	$Tonemapper.selected = Settings.setting_res.tonemapper
	if OS.get_name() == "Web":
		$Tonemapper.set_item_disabled(2, true)
		$Tonemapper.set_item_disabled(3, true)
		$Tonemapper.set_item_disabled(4, true)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

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
