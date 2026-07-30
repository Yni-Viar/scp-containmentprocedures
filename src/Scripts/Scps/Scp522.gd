extends Node3D
## SCP-522 base script
## Created by Yni, licensed under dual license: for SCP content - GPL 3, for non-SCP - MIT License
class_name Scp522

signal finished(has_body: PackedInt32Array)

## DORMANT - the carpet do nothing.
## ACTIVE - carpet absorbs blood.
enum Scp522State {DORMANT, ACTIVE}

## set SCP522State and apply animation.
@export var state:Scp522State = Scp522State.DORMANT:
	set(val):
		if is_equal_approx(animation_timer, 1):
			animation_timer = -1
		else:
			animation_timer = 1
		state = val
## Automatic.
@export var body_to_process: Node3D

var animation_timer: int = 0.0
## Format - [puppet class fraction, puppet class team]
var body_inside: PackedInt32Array = [-1, -1]

var timer: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if get_node_or_null("Armature/Skeleton3D/CopyTransformModifier3D") != null:
		match animation_timer:
			1:
				$Armature/Skeleton3D/CopyTransformModifier3D.active = true
				if $Armature/Skeleton3D/CopyTransformModifier3D.influence < 0.9990234375 && timer < 1.0:
					$Armature/Skeleton3D/CopyTransformModifier3D.influence = timer
				else:
					animation_timer = 0
					$Armature/Skeleton3D/CopyTransformModifier3D.influence = 1.0
			-1:
				if $Armature/Skeleton3D/CopyTransformModifier3D.influence > 0.0009765625 && timer < 1.0:
					$Armature/Skeleton3D/CopyTransformModifier3D.influence = 1.0 - timer
				else:
					$Armature/Skeleton3D/CopyTransformModifier3D.influence = 0.0
					animation_timer = 0
					$Armature/Skeleton3D/CopyTransformModifier3D.active = false
	if state == Scp522State.ACTIVE:
		timer += delta
		if body_to_process != null:
			if body_to_process is MovableNpc:
				if int(timer) % 8 == 0:
					body_to_process.health_manage(-10.0, 0, "GAME_OVER_SCP_522")
		elif timer > 10.0 || body_to_process == null:
			finished.emit(body_inside)
			state = Scp522State.DORMANT
			timer = 0.0

func _on_scp_522_trigger_body_entered(body: Node3D) -> void:
	# Catch the puppet!
	if state != Scp522State.ACTIVE:
		state = Scp522State.ACTIVE
		body_to_process = body
		if body is MovableNpc:
			#Achievement
			if Settings.setting_res.scp_study_progress_all.has("SCP-522"):
				if !Settings.setting_res.scp_study_progress_all["SCP-522"]:
					Settings.setting_res.scp_study_progress_all["SCP-522"] = true
					Settings.save_resource(Settings.setting_res)
			body_inside = [body.fraction, body.puppet_class.team]
			body.movement_freeze = true
		else:
			body_inside = [-1, -1]
