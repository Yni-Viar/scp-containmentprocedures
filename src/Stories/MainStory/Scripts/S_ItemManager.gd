extends ItemManager
## Made by Yni, licensed under MIT license.

## Used only when loading to prevent infinite loops.
@export var loading_startup: bool = false

## Do something, when item was removed
func _item_removed(path_to_item: String) -> void:
	if get_parent().get_node("StoryModeNode").save_data["added_map_items"].has(path_to_item):
		get_parent().get_node("StoryModeNode").save_data["added_map_items"].erase(path_to_item)
	else:
		get_parent().get_node("StoryModeNode").save_data["removed_map_items"].append(path_to_item)

## Do something, when item was added
func _item_added(path_to_item: String, item_id: int, pos: Vector3, state: Dictionary[String, Variant] = {}) -> void:
	if !loading_startup:
		get_parent().get_node("StoryModeNode").save_data["added_map_items"][path_to_item] = [item_id, pos, state]
