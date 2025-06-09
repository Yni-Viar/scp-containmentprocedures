extends RigidBody3D
## Created by Yni, licensed under MIT License
class_name Pickable

@export var item_id: int

func _on_collect_area_body_entered(body: Node3D) -> void:
	if body is MovableNpc:
		if body.is_player:
			get_tree().root.get_node("Game/UI/Inventory/Inventory").add_item(item_id)
