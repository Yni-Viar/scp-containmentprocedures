extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

## SCP-2306 function
func scp_2306():
	if get_parent().protagonist.get_node("UI/Inventory/Inventory").has_item(23):
		for item: Item in get_parent().protagonist.get_node("UI/Inventory/Inventory").get_items(23):
			item.action_args[0] = ["ItemCustom:1"]
		get_tree().root.get_node("Game/FoundationTask").do_task("task_5270_2306")
	get_parent().get_node("SoundStreamPlayer").stream = load("res://Sounds/Item/Scp2306/Original/Scp2306use.ogg")
	get_parent().get_node("SoundStreamPlayer").play()
