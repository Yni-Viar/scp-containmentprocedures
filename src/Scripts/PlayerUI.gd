extends Control
## Used by Inventory screen.
## Made by Yni, licensed under MIT license.

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _on_children_visibility_changed() -> void:
	# If inventory is visible - stop passing mouse clicks.
	for node in get_children():
		if node is Control:
			if node.visible:
				mouse_filter = Control.MOUSE_FILTER_STOP
				return
	mouse_filter = Control.MOUSE_FILTER_IGNORE
