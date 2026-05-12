extends Button
## Button with call support
## Used by dialogues
## Made by Yni, licensed under MIT license.
class_name DialogueButton

## Command to do
@export var action: CommandResource
## Path to dialogue (optional)
@export var dlg_host: BaseWindow

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	text = action.name
	pressed.connect(_on_click)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_click():
	if get_tree().root.get_node_or_null("Game") != null:
		get_tree().root.get_node("Game").protagonist._call_function(action.action_node_path, action.action_method_name, action.action_args)
		if dlg_host != null:
			dlg_host.queue_free()
