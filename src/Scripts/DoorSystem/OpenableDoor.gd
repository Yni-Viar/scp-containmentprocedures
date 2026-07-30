extends DoorBase
## Door, that can be opened by player
## Made by Yni, licensed under MIT License.
class_name OpenableDoor

var current_person: NodePath = NodePath()

func _on_enter_trigger_body_entered(body: Node3D) -> void:
	if body is MovableNpc:
		current_person = body.get_path()
		door_control(body.get_path())


func _on_enter_trigger_body_exited(body: Node3D) -> void:
	if body is MovableNpc:
		if body.get_path() == current_person && is_opened && (check_keycards && check_keycard(body.get_path())) != !check_keycards:
			door_close()
			current_person = NodePath()
