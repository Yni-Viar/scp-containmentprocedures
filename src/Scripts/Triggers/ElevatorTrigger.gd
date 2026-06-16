extends Area3D
## Made by Yni, licensed under MIT License.

## Local elevator path
@export var elevator_path: NodePath
## Global elevator path
@export var elevator_path_global: String
## Floor to call for NPCs
@export var current_floor: int
## NPC queue
@export var queue: int

var timer: float = 5.0

func _on_body_entered(body: Node3D) -> void:
	# If is player - show button, or add puppet to the queue
	if body is MovableNpc:
		if body.is_player:
			if !elevator_path.is_empty():
				get_tree().root.get_node("Game/UI").current_elevator = get_node(elevator_path)
			else:
				get_tree().root.get_node("Game/UI").current_elevator = get_node(elevator_path_global)
			get_tree().root.get_node("Game/UI/HBoxContainer/ElevatorButton").show()
		elif body.puppet_class.can_ride:
			queue += 1
			


func _on_body_exited(body: Node3D) -> void:
	# If is player, hide UI button, else remove queue entry.
	if body is MovableNpc:
		if body.is_player:
			get_tree().root.get_node("Game/UI/HBoxContainer/ElevatorButton").hide()
			get_tree().root.get_node("Game/UI/ElevatorMode").hide()
		elif body.puppet_class.can_ride:
			queue -= 1

func _physics_process(delta: float) -> void:
	# NPC queue processing.
	if queue > 0:
		if timer > 0.0:
			timer -= delta
		else:
			if !elevator_path.is_empty():
				get_node(elevator_path).call_elevator(current_floor)
			else:
				get_node(elevator_path_global).call_elevator(current_floor)
			timer = 5.0
