extends SkinnableHumanPuppetScript
## SCP-347 puppet script
## Created by Yni, licensed under dual license: for SCP content - GPL 3, for non-SCP - MIT License
class_name Scp347PuppetScript

## In earlier versions
#enum Mood {NORMAL, TRYING_TO_ESCAPE}

#@export var mood: Mood = Mood.NORMAL
#var mood_timer: float = 55.0
var blink_timer: float = 0.0
## Shows or hides infrared scan of SCP-347
var infrared_visibility: bool = false:
	set(val):
		infrared_visibility = val
		puppet_node.get_node(armature_name).visible = infrared_visibility

# Called when the node enters the scene tree for the first time.
func on_start_human() -> void:
	match Settings.current_season:
		Settings.Season.CHRISTMAS:
			puppet_node.get_node("Woman_body_rig/Skeleton3D/Woman_body").set_surface_override_material(0, load("res://Assets/Materials/Classes/Christmas/Scp347_scan_shader.tres"))
			puppet_node.get_node("Woman_body_rig/Skeleton3D/Woman_female_casualsuit01").set_surface_override_material(0, load("res://Assets/Materials/Classes/Christmas/Scp347_scan_shader.tres"))
			puppet_node.get_node("Woman_body_rig/Skeleton3D/Woman_short03").set_surface_override_material(0, load("res://Assets/Materials/Classes/Christmas/Scp347_scan_shader.tres"))
			puppet_node.get_node("Woman_body_rig/Skeleton3D/Woman_cortu_t-bar").set_surface_override_material(0, load("res://Assets/Materials/Classes/Christmas/Scp347_scan_shader.tres"))
			puppet_node.get_node("Woman_body_rig/Skeleton3D/Woman_low-poly").set_surface_override_material(0, load("res://Assets/Materials/Classes/Christmas/Scp347_scan_shader.tres"))
		Settings.Season.HALLOWEEN:
			puppet_node.get_node("Woman_body_rig/Skeleton3D/Woman_body").set_surface_override_material(0, load("res://Assets/Materials/Classes/Halloween/Scp347_scan_shader.tres"))
			puppet_node.get_node("Woman_body_rig/Skeleton3D/Woman_female_casualsuit01").set_surface_override_material(0, load("res://Assets/Materials/Classes/Halloween/Scp347_scan_shader.tres"))
			puppet_node.get_node("Woman_body_rig/Skeleton3D/Woman_short03").set_surface_override_material(0, load("res://Assets/Materials/Classes/Halloween/Scp347_scan_shader.tres"))
			puppet_node.get_node("Woman_body_rig/Skeleton3D/Woman_cortu_t-bar").set_surface_override_material(0, load("res://Assets/Materials/Classes/Halloween/Scp347_scan_shader.tres"))
			puppet_node.get_node("Woman_body_rig/Skeleton3D/Woman_low-poly").set_surface_override_material(0, load("res://Assets/Materials/Classes/Halloween/Scp347_scan_shader.tres"))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func on_update_human(delta: float) -> void:
	scp_347_infrared_blink(delta)
	#if !Settings.setting_res.zen_mode:
		#scp_347_mood_setter(delta)

## Shows for 8 seconds 347 position
func scp_347_infrared_blink(delta: float):
	if blink_timer > 0:
		blink_timer -= delta
	elif !infrared_visibility:
		infrared_visibility = true
		await get_tree().create_timer(0.5).timeout
		infrared_visibility = false
		blink_timer = 8.0

#func scp_347_mood_setter(delta: float) -> void:
	#if mood_timer > 0:
		#mood_timer -= delta
	#else:
		#if OS.has_feature("Lite"):
		#mood = Mood.NORMAL
		#else:
			#rng.randi_range(0, 1)
		#match mood:
			#Mood.NORMAL:
				# If SCP-347 follows player, her mood change do not affect following...
				#if get_parent().get_parent().follow_target != get_tree().root.get_node("Game/StaticPlayer").target_puppet_path:
					#get_parent().get_parent().wandering_system = MovableNpc.WanderingSystem.GENERIC_WANDER
					#get_parent().get_parent().follow_target = ""
			#Mood.TRYING_TO_ESCAPE:
				#get_parent().get_parent().wandering_system = MovableNpc.WanderingSystem.NONE
				#if get_tree().get_node_count_in_group("Scp347Exit") > 0 && get_parent().get_parent().follow_target.is_empty():
					## Trying to escape
					#get_parent().get_parent().follow_target = str(get_tree().get_first_node_in_group("Scp347Exit").get_path())
				#else:
					## Normal mood
					#mood = Mood.NORMAL
					#if get_parent().get_parent().follow_target != get_tree().root.get_node("Game/StaticPlayer").target_puppet_path:
						#get_parent().get_parent().wandering_system = MovableNpc.WanderingSystem.GENERIC_WANDER
						#get_parent().get_parent().follow_target = ""
		#mood_timer = rng.randf_range(15.0, 24.0)
