extends StaticBody3D
## SCP-812 trigger script
## Created by Yni, licensed under dual license: for SCP content - GPL 3, for non-SCP - MIT License

var flowing = false

@onready var waterflow: MeshInstance3D = $WaterFlow

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if flowing && waterflow.position.y < -9:
		waterflow.position.y += delta
	elif waterflow.visible && waterflow.position.y > -30.5:
		waterflow.position.y -= delta

func flow():
	$Waterfall.emitting = flowing
	$Waterfall2.emitting = flowing
	$Waterfall3.emitting = flowing
	waterflow.visible = flowing
	get_tree().root.get_node("Game/FoundationTask").do_task("task_812")


func _on_scp_812_trigger_body_entered(body: Node3D) -> void:
	if body is MovableNpc:
		if body.is_player:
			if !flowing:
				$AnimationPlayer.play("open_waterflow")
				flowing = true


func _on_scp_812_trigger_body_exited(body: Node3D) -> void:
	if body is MovableNpc:
		if body.is_player:
			if flowing:
				$AnimationPlayer.play_backwards("open_waterflow")
				flowing = false
