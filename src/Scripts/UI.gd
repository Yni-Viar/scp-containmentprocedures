extends Control
## Made by Yni, licensed under MIT License.

var exiting: bool = false

# Called when the node enters the scene tree for the first time.
#func _ready():
	#pass
#
#
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#


#func _on_seed_text_changed(new_text):
	#if new_text != "":
		#get_parent().get_node("FacilityGenerator").rng_seed = hash(new_text)
	#else:
		#get_parent().get_node("FacilityGenerator").rng_seed = -1
#
#
#func _on_generate_pressed():
	#get_parent().get_node("FacilityGenerator").clear()
	#get_parent().get_node("FacilityGenerator").prepare_generation()


func _on_back_pressed() -> void:
	Settings.set_pause_subtree(false)
	var menu: Node = load("res://Scenes/Menu.tscn").instantiate()
	get_tree().root.add_child(menu)
	Settings.call_deferred("override_main_scene", menu)
	get_tree().root.get_node("Game").queue_free()

func _on_foundation_task_task_done() -> void:
	for prev_task in $Tasks.get_children():
		prev_task.queue_free()
	for task in get_parent().get_node("FoundationTask").all_tasks:
		var label: Label = Label.new()
		label.add_theme_font_size_override("font_size", 20)
		label.text = task.public_name
		$Tasks.add_child(label)
	if get_parent().get_node("FoundationTask").all_tasks.size() == 0:
		match get_parent().get_node("FoundationTask").special_event:
			0: # neutral
				get_parent().finish_game(true, "GAME_WIN_1")
			1: # temporary
				get_parent().finish_game(true, "GAME_WIN_1")
			2: # gameover
				get_parent().finish_game(false, "GAME_OVER_3")


func _on_inventory_button_pressed() -> void:
	if $Inventory.visible:
		$Inventory.hide()
	else:
		$Inventory.show()


func _on_playing_area_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("click"):
		get_tree().root.get_node("Game/StaticPlayer").interact("Point")
		Input.action_release("click")


func _on_call_mtf_button_pressed() -> void:
	get_parent().call_mtf()
