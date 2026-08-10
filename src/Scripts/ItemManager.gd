extends Node3D
## Wrapper for Story mode saving items system
## Made by Yni, licensed under MIT License.
class_name ItemManager

## Do something, when item was removed
func _item_removed(path_to_item: String) -> void:
	pass

## Do something, when item was added
func _item_added(path_to_item: String, item_id: int, pos: Vector3, state: Dictionary[String, Variant] = {}) -> void:
	pass


func _on_child_entered_tree(node: Node) -> void:
	if node is Pickable:
		if node.item != null:
			if node.item.custom_properties != null:
				if !node.item.custom_properties.is_empty():
					_item_added(node.get_path(), node.item_id, node.global_position, node.item.custom_properties)
					return
		_item_added(node.get_path(), node.item_id, node.global_position)
