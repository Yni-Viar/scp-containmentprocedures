extends MeshInstance3D
## Used for available SCPs information.
## Created by Yni, licensed under dual license: for SCP content - GPL 3, for non-SCP - MIT License

@export var waypoints_and_groups: Dictionary[String, String] = {}
## Indexes starts with 0 - 0 means 1 word per line, 1 means 2 words per line.
@export var delimiter_after: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if mesh is TextMesh:
		call_deferred("waypoint_add")


func waypoint_add():
	var index: int = 0
	for waypoint in waypoints_and_groups:
		if get_tree().get_node_count_in_group(waypoints_and_groups[waypoint]) > 0 \
		 && !mesh.text.contains(waypoint):
			mesh.text += waypoint + ' '
			index += 1
			if index > delimiter_after:
				mesh.text += '\n'
				index = 0
	
