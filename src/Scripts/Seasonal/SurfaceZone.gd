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
	#if get_tree().root.get_node("Game").story_mode:
		#daytime_change = true

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
	#get_tree().root.get_node("Game").minutes = $DirectionalLight3D.rotation_degrees.x / 15.0 / 0.25
	
	#if daytime_change:
		#if $DirectionalLight3D.rotation_degrees.y > -90.0 || get_tree().root.get_node("Game").hours < 16:
			#
			## In this game, Sun goes from 8:00 to 16:00
			## 4.0 is spare time, because one time rotation goes below zero
			## 
			#var time_left = 4.0 + ($DirectionalLight3D.rotation_degrees.y / 15.0) / 2
			## 18 - time_left is hour amount
			#get_tree().root.get_node("Game").hours = 16 - int(time_left)
			## We want first two decimal values and divide them by 60 to get minutes and multiplying by 100 for int conversion.
			#get_tree().root.get_node("Game").minutes = int((ceil(time_left) - time_left) * 60)
		#else:
			## Next day
			#get_tree().root.get_node("Game").hours = 16
			#get_tree().root.get_node("Game").minutes = 0
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
			

func set_time(hours: int, minutes: int):
	$DirectionalLight3D.rotation.x = deg_to_rad(15.0 * (hours + 6) + minutes / 60.0 * 15.0)
