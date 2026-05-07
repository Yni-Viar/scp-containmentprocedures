extends Panel
## Tile inventory system
## Made by Yni, licensed under CC0
class_name Inventory

var game_data: GameData
@export var tile_size: int = 96
@export var max_tiles: Vector2i = Vector2i(4, 4)

var _items: Array[InventorySlot]
var hold_on_status_effect: Array[String]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	game_data = get_tree().root.get_node("Game").gamedata

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

## Adds item
func add_item(item_id: int):
	if item_id >= game_data.items.size():
		return
	var item_prefab: InventorySlot = InventorySlot.new()
	item_prefab.mouse_entered.connect(item_prefab._inside)
	item_prefab.mouse_exited.connect(item_prefab._outside)
	item_prefab.item_id = item_id
	item_prefab.texture = game_data.items[item_id].texture_tiled
	add_child(item_prefab)
	item_prefab.position = Vector2(-16, -16)
	_items.append(item_prefab)
	# Auto-align item in inventory
	for i in range(max_tiles.x):
		for j in range(max_tiles.y):
			if item_move(item_prefab, Vector2(tile_size * i + 8, tile_size * j + 8)):
				return
	# If there is no place - no item will be picked
	item_remove(item_prefab, true)

## Move item
func item_move(prefab: InventorySlot, pos: Vector2) -> bool:
	pos = pos.snappedf(tile_size)
	var prev_pos = prefab.position
	prefab.position = pos
	if prefab.get_global_rect().intersection(get_global_rect()) != prefab.get_global_rect():
		prefab.position = prev_pos
		return false
	for item in _items:
		if prefab.get_global_rect().intersects(item.get_global_rect()) && item != prefab:
			prefab.position = prev_pos
			return false
	return true

func has_item(id: int) -> bool:
	for node in get_children():
		if node is InventorySlot:
			if node.item_id == id:
				return true
	return false

## Removes item
func item_remove(item: InventorySlot, drop: bool) -> bool:
	for i in _items:
		if i == item:
			# Stop holding item
			if get_tree().root.get_node("Game").protagonist.get_node("PlayerModel").get_child_count() > 0:
				var puppet: BasePuppetScript = get_tree().root.get_node("Game").protagonist.get_node("PlayerModel").get_child(0)
				if puppet is HumanPuppetScript:
					puppet.hold_item(-1)
			# Stop status effect
			var status_effect: StatusEffectManager = get_node(get_tree().root.get_node("Game/StaticPlayer").target_puppet_path + "/StatusEffects")
			if game_data.items[item.item_id].status_effect_destroyable && (status_effect.get_status_effect_index(game_data.items[item.item_id].status_effect) != -1 || hold_on_status_effect.has(game_data.items[item.item_id].status_effect)):
				if hold_on_status_effect.has(game_data.items[item.item_id].status_effect):
					hold_on_status_effect.erase(game_data.items[item.item_id].status_effect)
				status_effect.apply_status_effect(game_data.items[item.item_id].status_effect, 0.0, 0.0)
			# Drop
			if drop:
				var pickable: Node3D = load(game_data.items[i.item_id].pickable_path).instantiate()
				pickable.position = get_tree().root.get_node("Game").protagonist.get_node("ItemSpawn").global_position
				get_tree().root.get_node("Game/Items").add_child(pickable)
				pass
			_items.erase(i)
			i.mouse_entered.disconnect(i._inside)
			i.mouse_exited.disconnect(i._outside)
			i.queue_free()
			return true
	print("No item for delete found")
	return false

func item_remove_by_id(id: int, drop: bool):
	for node in get_children():
		if node is InventorySlot:
			if node.item_id == id:
				item_remove(node, drop)

func use_item(item: InventorySlot):
	get_node(get_tree().root.get_node("Game/StaticPlayer").target_puppet_path)._call_function(game_data.items[item.item_id].action_node_path, game_data.items[item.item_id].action_method_name, game_data.items[item.item_id].action_args)
	if !game_data.items[item.item_id].status_effect.is_empty():
		if game_data.items[item.item_id].status_effect_timer > 0.375:
			await get_tree().create_timer(game_data.items[item.item_id].status_effect_timer).timeout
		var status_effect: StatusEffectManager = get_node(get_tree().root.get_node("Game/StaticPlayer").target_puppet_path + "/StatusEffects")
		# If the status effect is destroyable or is queued, turn off it, else effect will be turned on.
		if game_data.items[item.item_id].status_effect_destroyable && (status_effect.get_status_effect_index(game_data.items[item.item_id].status_effect) != -1 || hold_on_status_effect.has(game_data.items[item.item_id].status_effect)):
			if hold_on_status_effect.has(game_data.items[item.item_id].status_effect):
				hold_on_status_effect.erase(game_data.items[item.item_id].status_effect)
			status_effect.apply_status_effect(game_data.items[item.item_id].status_effect, 0.0, 0.0)
		else:
			status_effect.apply_status_effect(game_data.items[item.item_id].status_effect, game_data.items[item.item_id].status_effect_strength, game_data.items[item.item_id].status_effect_duration)
			# If effect is timed, put into hold_on_status_effect array, release after effect duration
			if game_data.items[item.item_id].status_effect_destroyable && game_data.items[item.item_id].status_effect_duration > 0.325:
				hold_on_status_effect.append(game_data.items[item.item_id].status_effect)
	if game_data.items[item.item_id].usage != 0:
		item_remove(item, game_data.items[item.item_id].usage == 2)

## the item could be dropped only inside inventory
func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	return true

func _drop_data(at_position: Vector2, data: Variant) -> void:
	item_move(data, at_position)
