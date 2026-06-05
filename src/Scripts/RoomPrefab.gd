extends StaticBody3D
## Room prefab script
## Made by Yni, licensed under MIT License.
class_name RoomPrefab

@export_node_path("RoomMesh") var mesh_paths: Array[NodePath]

# Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#pass # Replace with function body.
#
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass

## Activate SCP-649 effect on the room
func scp_649_activate(enable: bool):
	for mesh_path in mesh_paths:
		var mesh: RoomMesh = get_node_or_null(mesh_path)
		if mesh != null:
			if mesh.scp_649_floor_index != -1:
				if enable:
					mesh.set_surface_override_material(mesh.scp_649_floor_index, load("res://Shaders/SnowShader/snow.tres"))
				else:
					mesh.set_surface_override_material(mesh.scp_649_floor_index, null)
