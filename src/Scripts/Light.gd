extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Settings.setting_res.lighting == SettingsResource.Lighting.REALTIME && OS.get_name() != "Web" && OS.get_name() != "Android":
		for node in get_children():
			if node is Light3D:
				node.show()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
