extends Node3D
## Human and SCP-347 model-to-skinnablepuppetscript shim
## Made by Yni, licensed under CC0.

## Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#pass
#
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass

func footstep(key: String):
	if get_parent() is SkinnableHumanPuppetScript:
		get_parent().footstep(key)
