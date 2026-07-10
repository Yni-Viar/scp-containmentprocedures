extends Node

@export_node_path("SurfaceZone") var surface_zone_path: NodePath

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	pass

func surface_zone_start():
	get_node(surface_zone_path).set_time(8, 0)

func surface_zone_update(delta: float):
	pass
	#if get_tree().root.get_node("Game/FoundationTask").get_amount_of_active_tasks() > 0:
				#get_tree().root.get_node("Game").finish_game(true, "GAME_OVER_TIMES_UP")
			#else:
				#match Settings.setting_res.current_day:
					#1:
						#get_tree().root.get_node("Game").finish_game(true, "GAME_WIN_DAY1")
					#2:
						#get_tree().root.get_node("Game").finish_game(true, "GAME_WIN_DAY2")
					#3:
						#get_tree().root.get_node("Game").finish_game(true, "GAME_WIN_DAY3")
					#4:
						#get_tree().root.get_node("Game").finish_game(true, "GAME_WIN_DAY4")
					#5:
						#get_tree().root.get_node("Game").finish_game(true, "GAME_WIN_DAY5")
						#Settings.setting_res.casual_game_unlocked = true
			#Settings.setting_res.current_day += 1
