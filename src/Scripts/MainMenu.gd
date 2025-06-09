extends Control
## Main Menu
## Made by Yni, licensed under MIT license.

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Set the region (needed for obeying contries' laws)
	Settings.region = OS.get_locale()
	Settings.touchscreen = DisplayServer.is_touchscreen_available()
	#var index: int = 0
	#for node in $LorePanel/ScrollContainer/VBoxContainer.get_children():
		# Easy bit-field checking
		#node.visible = (Settings.setting_res.secrets >> index) % 2 == 1
		#index += 1
	
	$GameSettings/CiSpawn.selected = Settings.setting_res.ci_spawn
	$GameSettings/TimeLimited.button_pressed = Settings.setting_res.time_limited
	
	# Display game ratings in main menu in some countries, this will replace the game logo.
	if Settings.legal_req:
		match Settings.region:
			"ru_RU":
				# New upcoming Russian law.
				$LawRegulation.texture = load("res://UI/MainMenu/LawRegulation/RU.png")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_play_pressed() -> void:
	play()


func _on_credits_pressed() -> void:
	$CreditsContainer.visible = $Credits.button_pressed


func play():
	var game: GameCore = load("res://Scenes/Game.tscn").instantiate()
	if !$GameSettings/Seed.text.is_empty():
		game.map_seed = $GameSettings/Seed.text
	if $GameSettings/CiSpawn.selected - 1 >= 0:
		game.ci_probability = $GameSettings/CiSpawn.selected - 1
	game.time_limited = $GameSettings/TimeLimited.button_pressed
	get_tree().root.add_child(game)
	Settings.call_deferred("override_main_scene", game)
	queue_free()

func _on_custom_play_pressed() -> void:
	$CustomGamePanel.show()


func _on_customplay_back_button_pressed() -> void:
	$CustomGamePanel.hide()


func _on_ci_spawn_item_selected(index: int) -> void:
	Settings.setting_res.ci_spawn = index
	Settings.save_resource(Settings.setting_res)


func _on_time_limited_toggled(toggled_on: bool) -> void:
	Settings.setting_res.time_limited = toggled_on
	Settings.save_resource(Settings.setting_res)
