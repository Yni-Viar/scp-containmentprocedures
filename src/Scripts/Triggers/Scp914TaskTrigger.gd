extends Area3D
## Created by Yni, licensed under dual license: for SCP content - GPL 3, for non-SCP - MIT License

const EXPERIMENTS = true
## Syntax - [ [ input, [ output ] ] ]
var available_experiments: Array[Array] = [[0, [2]], [0, [3]],  [6, [5]], [6, [8]], [15, [18]]]
var current_experiments: Array[int] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node3D) -> void:
	if body is MovableNpc: # enable 914 control
		if body.is_player:
			get_tree().root.get_node("Game/UI/HBoxContainer/Scp914Button").show()
	if body is Pickable && EXPERIMENTS: #task processing
		for i in range(available_experiments.size()):
			if get_tree().root.get_node("Game/FoundationTask").has_task("task_914_exp_" + str(i+1)):
				# Add support for multiple 914 outputs
				if current_experiments.has(i):
					for j in range(available_experiments[i][1].size()):
						if body.item_id == available_experiments[i][1][j]:
							get_tree().root.get_node("Game/FoundationTask").do_task("task_914_exp_" + str(i+1))
				if body.item_id == available_experiments[i][0] && !current_experiments.has(i):
					current_experiments.append(i)

func _on_body_exited(body: Node3D) -> void:
	if body is MovableNpc:
		if body.is_player:
			get_tree().root.get_node("Game/UI/HBoxContainer/Scp914Button").hide()
			get_tree().root.get_node("Game/UI/Scp914Panel").hide()
