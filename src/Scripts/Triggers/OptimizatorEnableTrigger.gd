extends Area3D
## Made by Yni, licensed under MIT License.

## Node-to-optimize path
@export_node_path("Node3D") var optimize_node_path: NodePath

func _on_body_entered(body: Node3D) -> void:
	get_node(optimize_node_path).show()


func _on_body_exited(body: Node3D) -> void:
	get_node(optimize_node_path).hide()
