extends InteractableStatic
## SCP-649 function
## Created by Yni, licensed under dual license: for SCP content - GPL 3, for non-SCP - MIT License

## The main toggle.
@export var is_opened: bool = false
## Snow spreading speed.
@export var speed: float = 0.125
## Puppets with frozen effect.
var frozen_puppets: Array[MovableNpc] = []
var timer: float = 4.0

## Toggle ice age.
func interact(player: Node3D):
	if !is_opened:
		is_opened = true
	else:
		is_opened = false
	speed = 0.125
	super.interact(player)

func _physics_process(delta: float) -> void:
	# Creating or destructing ice age.
	if get_node_or_null("ColdArea/CollisionShape3D") != null:
		if is_opened && $ColdArea/CollisionShape3D.shape.radius < 100.0:
			$ColdArea/CollisionShape3D.shape.radius += delta * speed
			speed += delta * 0.125
		elif $ColdArea/CollisionShape3D.shape.radius > 0.0625:
			$ColdArea/CollisionShape3D.shape.radius -= delta * speed
			if speed < 2.0:
				speed += delta * 0.125
	if timer > 0:
		timer -= delta
	else:
		for puppet in frozen_puppets:
			# Freeze...
			puppet.health_manage(-5.0, 1)
		timer = 4.0

func _on_cold_area_body_entered(body: Node3D) -> void:
	if body is RoomPrefab:
		#Achievement
		if Settings.setting_res.scp_study_progress_christmas.has("SCP-649"):
			if !Settings.setting_res.scp_study_progress_christmas["SCP-649"]:
				Settings.setting_res.scp_study_progress_christmas["SCP-649"] = true
				Settings.save_resource(Settings.setting_res)
		body.scp_649_activate(true)
	if body is MovableNpc:
		if body.current_health.size() >= 2:
			frozen_puppets.append(body)

func _on_cold_area_body_exited(body: Node3D) -> void:
	if body is RoomPrefab:
		body.scp_649_activate(false)
	if body is MovableNpc:
		if frozen_puppets.has(body):
			frozen_puppets.erase(body)
