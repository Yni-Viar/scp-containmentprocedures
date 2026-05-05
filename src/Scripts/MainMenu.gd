extends Control
## Main Menu
## Made by Yni, licensed under MIT license.

# Called when the node enters the scene tree for the first time.
func _enter_tree() -> void:
	if OS.has_feature("Lite"):
		$LiteWarning.show()
	
	if RenderingServer.get_current_rendering_method() != "gl_compatibility":
		Settings.dialogue_window("GODOT_RD_STATE", "ATTENTION")
	
	#var index: int = 0
	#for node in $LorePanel/ScrollContainer/VBoxContainer.get_children():
		# Easy bit-field checking
		#node.visible = (Settings.setting_res.secrets >> index) % 2 == 1
		#index += 1
	
	$GameSettings/TimeLimited.button_pressed = Settings.setting_res.time_limited
	$GameSettings/ZenMode.button_pressed = Settings.setting_res.zen_mode
	
	# Display game ratings in main menu in some countries, this will replace the game logo.
	if Settings.legal_req:
		match Settings.region:
			"ru_RU":
				# New upcoming Russian law.
				$Logo.texture = load("res://UI/MainMenu/LawRegulation/RU.png")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_play_pressed() -> void:
	play()


func _on_credits_pressed() -> void:
	$CreditsContainer.visible = $Credits.button_pressed


func play():
	Settings.loader("res://Scenes/Game.tscn", {
		"map_seed": hash($GameSettings/Seed.text) if !$GameSettings/Seed.text.is_empty() else -1,
		"time_limited": $GameSettings/TimeLimited.button_pressed
	})
	
	#$FakeLoadingScreen.show()
	#
	#var game: GameCore = load("res://Scenes/Game.tscn").instantiate()
	#if !$GameSettings/Seed.text.is_empty():
		#game.map_seed = hash($GameSettings/Seed.text)
	#game.time_limited = $GameSettings/TimeLimited.button_pressed
	#get_tree().root.add_child(game)
	#Settings.call_deferred("override_main_scene", game)
	#queue_free()


func _on_time_limited_toggled(toggled_on: bool) -> void:
	Settings.setting_res.time_limited = toggled_on
	Settings.save_resource(Settings.setting_res)


func _on_help_button_pressed() -> void:
	$Tutorial.show()


func _on_zen_mode_toggled(toggled_on: bool) -> void:
	$GameSettings/TimeLimited.disabled = toggled_on
	if toggled_on:
		$GameSettings/TimeLimited.button_pressed = false
	Settings.setting_res.zen_mode = toggled_on
	Settings.save_resource(Settings.setting_res)


func _on_enable_sound_toggled(toggled_on: bool) -> void:
	if toggled_on:
		Settings.setting_res.music_volume = 1.0
		$EnableSound.texture_normal = load("res://UI/MainMenu/MusicEnabled.png")
		
	else:
		Settings.setting_res.music_volume = 0.0
		$EnableSound.texture_normal = load("res://UI/MainMenu/MusicDisabled.png")
	Settings.audio_settings(1, Settings.setting_res.music_volume)
	Settings.save_resource(Settings.setting_res)


func _on_story_mode_pressed() -> void:
	$StoryUI.show()


func _on_story_back_pressed() -> void:
	$StoryUI.hide()
	$StoryUI/ScrollContainer.show()
	$StoryUI/EasterEgg.hide()


func _on_settings_button_pressed() -> void:
	$Settings.show()


func _on_seed_text_changed(new_text: String) -> void:
	if new_text.to_lower() == "feature_beta":
		Settings.beta_mode = true
		$HBoxContainer/StoryMode.show()
		$GameSettings/Seed.text = ""
	if new_text.to_lower() == "spoilers":
		$HBoxContainer/HelpButton.show()
	if new_text.to_lower() == "yenjeai":
		$StoryUI/ScrollContainer/HBoxContainer/EasterEggActivator.show()
	elif $StoryUI/ScrollContainer/HBoxContainer/EasterEggActivator.visible:
		$StoryUI/ScrollContainer/HBoxContainer/EasterEggActivator.hide()


func _on_easter_egg_activator_pressed() -> void:
	$StoryUI/ScrollContainer.hide()
	$StoryUI/EasterEgg.show()
