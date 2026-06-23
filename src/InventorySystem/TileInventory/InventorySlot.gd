extends TextureRect
## Inventory slot
## Made by Yni, licensed under CC0.
class_name InventorySlot

## Item ID
@export var item_id: int
## Item
@export var item: Item
var mouse_inside: bool = false
var item_use_cooldown: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.double_click && get_parent().get_parent().visible && mouse_inside:
			use_item()
	if event is InputEventScreenTouch:
		if event.double_tap && get_parent().get_parent().visible && mouse_inside:
			use_item()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

## Set texture preview
func _get_drag_data(at_position):
	var preview: TextureRect = TextureRect.new()
	preview.texture = texture
	set_drag_preview(preview)
	return self

func _inside():
	mouse_inside = true

func _outside():
	mouse_inside = false

func use_item():
	if !item_use_cooldown:
		get_parent().use_item(self)
		item_use_cooldown = true
		await get_tree().create_timer(0.5).timeout
		item_use_cooldown = false
