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
	item_prefab.item = game_data.items[item_id].duplicate_deep()
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

func add_item_with_state(item: Item):
	var item_prefab: InventorySlot = InventorySlot.new()
	item_prefab.mouse_entered.connect(item_prefab._inside)
	item_prefab.mouse_exited.connect(item_prefab._outside)
	item_prefab.item = item
	item_prefab.texture = item.texture_tiled
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
			if node.item.id == id:
				return true
	return false

## Removes item
func item_remove(item: InventorySlot, drop: bool) -> bool:
	for i in _items:
		if i == item:
			# Stop holding item
			if get_tree().root.get_node("Game").protagonist.get_node("PlayerModel").get_child_count() > 0:
				var puppet: BasePuppetScript = get_tree().root.get_node("Game").protagonist.get_node("PlayerModel").get_child(0)
				if puppet is SkinnableHumanPuppetScript:
					puppet.hold_item(-1)
			# Stop status effect
			var status_effect: StatusEffectManager = get_node(get_tree().root.get_node("Game/StaticPlayer").target_puppet_path + "/StatusEffects")
			if item.item.status_effect_destroyable && (status_effect.get_status_effect_index(item.item.status_effect) != -1 || hold_on_status_effect.has(item.item.status_effect)):
				if hold_on_status_effect.has(item.item.status_effect):
					hold_on_status_effect.erase(item.item.status_effect)
				status_effect.apply_status_effect(item.item.status_effect, 0.0, 0.0)
			# Drop
			if drop:
				var pickable: Node3D = load(item.item.pickable_path).instantiate()
				if pickable is Pickable:
					pickable.item = item.item
					pickable.item_properties = item.item.custom_properties
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
			if node.item.id == id:
				item_remove(node, drop)

func use_item(item: InventorySlot):
	# Apply custom properties to the item's command
	for i in range(0, item.item.action_args.size()):
		if item.item.action_args[i] is String:
			# Check if ItemCustom: in string AND after ItemCustom there is valid int index of custom property
			if item.item.action_args[i].begins_with("ItemCustom:") && item.item.action_args[i].get_slice(":", 1).is_valid_int():
				item.item.action_args[i] = item.item.custom_properties[int(item.item.action_args[i].get_slice(":", 1))]
		elif item.item.action_args[i] is Array:
			for j in range(0, item.item.action_args[i].size()):
				if item.item.action_args[i][j] is String:
					# Check if ItemCustom: in string AND after ItemCustom there is valid int index of custom property
					if item.item.action_args[i][j].begins_with("ItemCustom:") && item.item.action_args[i][j].get_slice(":", 1).is_valid_int():
						item.item.action_args[i][j] = item.item.custom_properties[int(item.item.action_args[i][j].get_slice(":", 1))]
	# Apply item command
	get_node(get_tree().root.get_node("Game/StaticPlayer").target_puppet_path)._call_function(item.item.action_node_path, item.item.action_method_name, item.item.action_args)
	# Status effect management
	if !item.item.status_effect.is_empty():
		if item.item.status_effect_timer > 0.375:
			await get_tree().create_timer(item.item.status_effect_timer).timeout
		var status_effect: StatusEffectManager = get_node(get_tree().root.get_node("Game/StaticPlayer").target_puppet_path + "/StatusEffects")
		# If the status effect is (destroyable and toggleable) or is queued, turn it off, else effect will be turned on.
		if item.item.status_effect_destroyable && (status_effect.get_status_effect_index(item.item.status_effect) != -1 && item.item.status_effect_toggleable  \
		  || hold_on_status_effect.has(item.item.status_effect)):
			if hold_on_status_effect.has(item.item.status_effect):
				hold_on_status_effect.erase(item.item.status_effect)
			status_effect.apply_status_effect(item.item.status_effect, 0.0, 0.0)
		else:
			status_effect.apply_status_effect(item.item.status_effect, item.item.status_effect_strength, item.item.status_effect_duration)
			# If effect is timed and toggleable, put into hold_on_status_effect array, release after effect duration
			if item.item.status_effect_destroyable && item.item.status_effect_duration > 0.325 && item.item.status_effect_toggleable:
				hold_on_status_effect.append(item.item.status_effect)
	if item.item.usage != 0:
		item_remove(item, item.item.usage == 2)

## Gets all items in inventory with this `item_id`
func get_items(item_id: int) -> Array[Item]:
	var result: Array[Item] = []
	for item in _items:
		if item.item.id == item_id:
			result.append(item.item)
	return result

## Gets all items in inventory
func get_all_items() -> Array[Item]:
	var result: Array[Item] = []
	for item in _items:
		result.append(item.item)
	return result

## the item could be dropped only inside inventory
func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	return true

func _drop_data(at_position: Vector2, data: Variant) -> void:
	item_move(data, at_position)
