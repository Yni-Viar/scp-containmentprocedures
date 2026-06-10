extends Node
## Made by Yni, licensed under MIT License.

## Stages of the developing
enum Stages {release, testing, dev}
enum ItemType {item, map_object, npc}
enum Season {NONE, WINTER, SPRING, SUMMER, AUTUMN, CHRISTMAS, HALLOWEEN}

signal settings_saved

## Game's data compatibility for modding.
const DATA_COMPATIBILITY: String = "9.0.0"
## Game's data compatibility for modding.
const CURRENT_STAGE: Stages = Stages.dev
## If we don't specify regions, which have additional legal requirements, we are in trouble.
## Available flags:
## generic_XX, where XX is country id
## no_halloween - disables Halloween for this region
## no_neural_ai - disables AI interactions
const LEGAL_REQ_REGIONS: Dictionary[String, PackedStringArray] = {
	"ru_RU": ["generic_ru"]
}

const PLATFORM_REQS: Dictionary[String, PackedStringArray] = {
}

var features: Dictionary[String, bool] = {
	"no_halloween": false,
	"no_neural_ai": false
}
## Touchscreen check
var touchscreen: bool = false
## Settings resource
var setting_res: SettingsResource

var paused_game = false
## If we don't specify regions, which have additional legal requirements, we are in trouble.
var region: String = "":
	set(val):
		region = val
		legal_req = is_legal_req()
var legal_req: bool = false
var current_season: Season = Season.NONE

## Beta mode
var beta_mode: bool = false

func _init():
	load_resource()
	audio_settings(1, setting_res.music_volume)
	# Set the region (needed for obeying contries' laws)
	region = OS.get_locale()
	if legal_req:
		var l_requirements: Array = LEGAL_REQ_REGIONS[region]
		for req in l_requirements:
			features[req] = true
	
	if PLATFORM_REQS.has(OS.get_name()):
		var platform_requirements: Array = PLATFORM_REQS[OS.get_name()]
		for req in platform_requirements:
			features[req] = true

func _ready() -> void:
	change_renderer()
	if OS.get_name() == "Web":
		get_tree().root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP
	Settings.touchscreen = DisplayServer.is_touchscreen_available()
	season_checker()
	Console.add_command("beta_mode_features", beta_mode_features)
	Console.add_command("beta_mode_enable", beta_mode_enable, ["keyword"], 1)

## Sometimes ago it was a great function. Now it is just a stub, that calls ResourceStorage and loads settings
func load_resource():
	if OS.get_name() != "Web":
		var settings_from_file = ResourceStorage.load_resource("user://Settings.bin", "SettingsResource")
		if settings_from_file != null:
			setting_res = settings_from_file
			set_default_keybinds()
		else:
			load_default_settings()
	else:
		load_default_settings()
		set_default_keybinds()

func load_default_settings():
	if OS.get_name() != "Web" && OS.get_name() != "Android":
		var res = load("res://Scripts/SettingsResource/Presets/OpenGL/Low.tres")
		save_resource(res)
		setting_res = res
	else:
		var res = load("res://Scripts/SettingsResource/Presets/OpenGL/Lowest.tres")
		save_resource(res)
		setting_res = res
	set_default_keybinds()

## Sometimes ago it was a great function. Now it is just a stub, that calls ResourceStorage and saves settings
func save_resource(res):
	if OS.get_name() != "Web":
		ResourceStorage.save_resource("user://Settings.bin", res)
		emit_signal("settings_saved")

## Check current season, based on PC time.
func season_checker():
	match Time.get_datetime_dict_from_system()["month"]:
		1:
			if Time.get_datetime_dict_from_system()["day"] <= 7:
				current_season = Season.CHRISTMAS
			else:
				current_season = Season.WINTER
		2:
			current_season = Season.WINTER
		3, 4, 5:
			current_season = Season.SPRING
		6, 7, 8:
			current_season = Season.SUMMER
		9, 11: # this was NOT intended!!!
			current_season = Season.AUTUMN
		10:
			if !feature_legality_checker("no_halloween"):
				current_season = Season.HALLOWEEN
			else:
				current_season = Season.AUTUMN
		12:
			current_season = Season.CHRISTMAS
		_:
			print("Date not available")
			current_season = Season.NONE

## Initial region checking
func is_legal_req() -> bool:
	return LEGAL_REQ_REGIONS.has(region)

## Check if the feature is enabled
func feature_legality_checker(feature: String) -> bool:
	return features[feature]

## Set audio.
func audio_settings(bus: int, val: float):
	AudioServer.set_bus_volume_db(bus, linear_to_db(val))
	if val < 0.01:
		AudioServer.set_bus_mute(bus, true)
	elif val >= 0.01 && AudioServer.is_bus_mute(bus):
		AudioServer.set_bus_mute(bus, false)	

## Overrides main scene. Only used for LoadingScreen.
func override_main_scene(scene: Node):
	get_tree().current_scene = scene

## Sets default keybinds.
func set_default_keybinds():
	for value in setting_res.keybinds.keys():
		set_keybind(value, setting_res.keybinds[value][0], setting_res.keybinds[value][1])

## Keybind backend.
func set_keybind(action_name: String, key_type: int, key: int):
	InputMap.action_erase_events(action_name)
	match key_type:
		0:
			var event: InputEventKey = InputEventKey.new()
			event.physical_keycode = key as Key
			InputMap.action_add_event(action_name, event)
		1:
			var event: InputEventMouseButton = InputEventMouseButton.new()
			event.button_index = key as MouseButton
			InputMap.action_add_event(action_name, event)
		2:
			print("Gamepad support is not implemented.")
	setting_res.keybinds[action_name] = [key_type, key]
	save_resource(setting_res)

## Current season check
func season_feature_checker(season_check: Season) -> bool:
	if current_season == season_check || \
	 season_check == Season.NONE && current_season <= 4:
		return true
	else:
		return false

## Toggle loading screen.
func loader(file_path_to_load: String, parameters: Dictionary[String, Variant]):
	if get_child_count() > 0:
		if get_child(0) is LoadingScreen:
			return
	var loading_screen: LoadingScreen = load("res://Scenes/LoadingScreen.tscn").instantiate()
	loading_screen.file_path_to_load = file_path_to_load
	loading_screen.parameters = parameters
	
	add_child(loading_screen)

func beta_mode_enable(keyword: Variant):
	if keyword is String:
		if keyword == "feature_beta":
			beta_mode = true

## GDsh command.
## List current beta features.
func beta_mode_features():
	Console.print_info("""Beta features:
	
	- Story mode UI.
	- Neural AI for Web platform
	
	To enable beta features, call in thsi console this command:
	[b]beta_mode_enable feature_beta[/b]
	""")

## Creates dialogue window
## Text is message to show, title is window title and button_actions (optional, only used ingame) is used for choices.
func dialogue_window(text: String, title: String = "", fixed_size: bool = true, button_actions: Array[CommandResource] = []):
	# Create window
	var window: BaseWindow = BaseWindow.new()
	window.deletable = true
	window.theme = load("res://UITheme.tres")
	if !title.is_empty():
		window.title = title
	window.initial_position = Window.WINDOW_INITIAL_POSITION_CENTER_MAIN_WINDOW_SCREEN
	window.unresizable = fixed_size
	window.size = Vector2i(640, 320)
	# Create UI for dialogue
	var ui: Control = Control.new()
	ui.size = Vector2(640, 320)
	window.add_child(ui)
	# Create message
	var message_label: RichTextLabel = RichTextLabel.new()
	message_label.size = Vector2(640, 276)
	message_label.text = text
	ui.add_child(message_label)
	# If ingame
	if get_tree().root.get_node_or_null("Game") != null:
		# Add scroll container for buttons
		var scroll_container: ScrollContainer = ScrollContainer.new()
		scroll_container.size = Vector2(640, 44)
		scroll_container.position = Vector2(0, 276)
		ui.add_child(scroll_container)
		# Add horizontal contaier for buttons
		var hbox_container: HBoxContainer = HBoxContainer.new()
		scroll_container.add_child(hbox_container)
		# Add buttons
		for action in button_actions:
			var button: DialogueButton = DialogueButton.new()
			button.action = action
			button.dlg_host = window
			hbox_container.add_child(button)
	add_child(window)

## Works ONLY on PCs
func change_renderer():
	if OS.get_name() != "Web" && OS.get_name() != "Android":# && !Engine.is_editor_hint():
		match Settings.setting_res.renderer:
			0:
				if RenderingServer.get_current_rendering_method() != "gl_compatibility":
					OS.set_restart_on_exit(true, ["--rendering-method", "gl_compatibility"])
					get_tree().quit()
			1:
				if RenderingServer.get_current_rendering_method() != "mobile":
					OS.set_restart_on_exit(true, ["--rendering-method", "mobile"])
					get_tree().quit()
			2:
				if RenderingServer.get_current_rendering_method() != "forward_plus":
					OS.set_restart_on_exit(true, ["--rendering-method", "forward_plus"])
					get_tree().quit()
