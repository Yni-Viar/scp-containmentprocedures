extends Control
## Main Menu
## Made by Yni, licensed under MIT license.

# Called when the node enters the scene tree for the first time.
func _enter_tree() -> void:
	var total_amount: int = Settings.setting_res.scp_study_progress_all.size()
	var completed_amount: int = 0
	for progress in Settings.setting_res.scp_study_progress_all:
		if Settings.setting_res.scp_study_progress_all[progress]:
			completed_amount += 1
		else:
			var label: Label = Label.new()
			label.text = progress
			$Achievements/ScrollContainer/HBoxContainer.add_child(label)
	if OS.has_feature("Lite"):
		$LiteWarning.show()
	else:
		total_amount += Settings.setting_res.scp_study_progress_full.size()
		for progress in Settings.setting_res.scp_study_progress_full:
			if Settings.setting_res.scp_study_progress_full[progress]:
				completed_amount += 1
			else:
				var label: Label = Label.new()
				label.text = progress
				$Achievements/ScrollContainer/HBoxContainer.add_child(label)
		if randf() > 0.75:
			$AudioStreamPlayer.stream = load("res://Sounds/Music/Original/Optional/SCP_MainTheme_v2.ogg")
	
	$Achievements/ProgressBar.max_value = total_amount
	$Achievements/ProgressBar.value = completed_amount
	
	#var index: int = 0
	#for node in $LorePanel/ScrollContainer/VBoxContainer.get_children():
		# Easy bit-field checking
		#node.visible = (Settings.setting_res.secrets >> index) % 2 == 1
		#index += 1
	
	
	# Display game ratings in main menu in some countries, this will replace the game logo.
	if Settings.legal_req && !Settings.IS_STORE_BUILD:
		match Settings.region:
			"ru_RU":
				# New upcoming Russian law.
				$Logo.texture = load("res://UI/MainMenu/LawRegulation/RU.png")
	
	await get_tree().physics_frame
	
	if Settings.setting_res.free_mode_unlocked:
		$HBoxContainer/Play.show()
		$GameSettingsContainer.show()
	
	if completed_amount == total_amount:
		$Achievements/Info2.text = "CASUAL_MODE_PROGRESS_2"
		$Achievements/ScrollContainer.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass


func _on_play_pressed() -> void:
	play()


func _on_credits_pressed() -> void:
	$CreditsContainer.visible = $Credits.button_pressed


func play():
	Settings.loader("res://Scenes/Game.tscn", {
		"map_seed": hash($HBoxContainer/Seed.text) if !$HBoxContainer/Seed.text.is_empty() else -1,
		"map_seed_name": $HBoxContainer/Seed.text if !$HBoxContainer/Seed.text.is_empty() else "random"
	})
	
	#$FakeLoadingScreen.show()
	#
	#var game: GameCore = load("res://Scenes/Game.tscn").instantiate()
	#if !$HBoxContainer/Seed.text.is_empty():
		#game.map_seed = hash($HBoxContainer/Seed.text)
	#game.time_limited = $GameSettingsContainer/GameSettings/TimeLimited.button_pressed
	#get_tree().root.add_child(game)
	#Settings.call_deferred("override_main_scene", game)
	#queue_free()


func _on_help_button_pressed() -> void:
	$Tutorial.show()


func _on_zen_mode_toggled(toggled_on: bool) -> void:
	$GameSettingsContainer/GameSettings/TimeLimited.disabled = toggled_on
	if toggled_on:
		$GameSettingsContainer/GameSettings/TimeLimited.button_pressed = false
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
	if $HBoxContainer/Seed.text == "yenjeai":
		$StoryUI.show()
	else:
		Settings.loader("res://Scenes/Game.tscn", {
			"story_mode": true,
			"map_seed": hash($HBoxContainer/Seed.text) if !$HBoxContainer/Seed.text.is_empty() else -1,
			"map_seed_name": $HBoxContainer/Seed.text if !$HBoxContainer/Seed.text.is_empty() else "random"
		})


func _on_story_back_pressed() -> void:
	$StoryUI.hide()


func _on_settings_button_pressed() -> void:
	$Settings.show()


func _on_seed_text_changed(new_text: String) -> void:
	pass
