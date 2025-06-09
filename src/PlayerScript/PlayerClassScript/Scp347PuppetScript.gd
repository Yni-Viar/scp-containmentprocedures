extends HumanPuppetScript
## SCP-347 puppet script
## Created by Yni, licensed under dual license: for SCP content - GPL 3, for non-SCP - MIT License
class_name Scp347PuppetScript

enum Mood {NORMAL, TRYING_TO_ESCAPE}

@export var mood: Mood = Mood.NORMAL
var mood_timer: float = 30.0
var blink_timer: float = 0.0
## Shows or hides infrared scan of SCP-347
var infrared_visibility: bool = true:
	set(val):
		infrared_visibility = val
		get_node(armature_name).visible = val

# Called when the node enters the scene tree for the first time.
#func on_start_human() -> void:
	#pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func on_update_human(delta: float) -> void:
	scp_347_infrared_blink(delta)
	scp_347_mood_setter(delta)

## Shows for 8 seconds 347 position
func scp_347_infrared_blink(delta: float):
	if blink_timer > 0:
		blink_timer -= delta
	else:
		infrared_visibility = false
		await get_tree().create_timer(2.0).timeout
		infrared_visibility = true
		blink_timer = 8.0

func scp_347_mood_setter(delta: float) -> void:
	if mood_timer > 0:
		mood_timer -= delta
	else:
		mood = rng.randi_range(0, 1)
		match mood:
			Mood.NORMAL:
				# If SCP-347 follows player, her mood change do not affect following...
				if get_parent().get_parent().follow_target != get_tree().root.get_node("Game/StaticPlayer").target_puppet_path:
					get_parent().get_parent().wandering = true
					get_parent().get_parent().follow_target = ""
			Mood.TRYING_TO_ESCAPE:
				get_parent().get_parent().wandering = false
				if get_tree().get_node_count_in_group("Scp347Exit") > 0 && get_parent().get_parent().follow_target.is_empty():
					# Trying to escape
					get_parent().get_parent().follow_target = str(get_tree().get_first_node_in_group("Scp347Exit").get_path())
				else:
					# Normal mood
					mood = Mood.NORMAL
					if get_parent().get_parent().follow_target != get_tree().root.get_node("Game/StaticPlayer").target_puppet_path:
						get_parent().get_parent().wandering = true
						get_parent().get_parent().follow_target = ""
		mood_timer = rng.randf_range(15.0, 24.0)
