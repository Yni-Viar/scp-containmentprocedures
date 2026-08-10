extends Area3D
## SCP-522 task trigger script
## Created by Yni, licensed under dual license: for SCP content - GPL 3, for non-SCP - MIT License

var class_d_amount: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.



func _on_scp_522_finished(has_body: PackedInt32Array) -> void:
	if has_body.size() == 2:
		if has_body[0] == 0 && has_body[1] == 2:
			get_tree().root.get_node("Game/FoundationTask").do_task("task_522")
