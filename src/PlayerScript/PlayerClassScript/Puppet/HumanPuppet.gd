extends Node3D
## Made by Yni, licensed under MIT License.
## Contains Godot Docs entries under CC-BY 3.0

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
