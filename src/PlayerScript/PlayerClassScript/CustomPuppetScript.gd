extends SkinnablePuppetScript
## Plugin-based puppet script
## Created by Yni, licensed under dual license: for SCP content - GPL 3, for non-SCP - MIT License

## Trigger type
enum TriggerShape {SPHERE, BOX, CAPSULE, CYLINDER}

## Trigger path. If trigger does not exist, there is empty string
var trigger: NodePath = ""

# Called when the node enters the scene tree for the first time.
func on_spawned() -> void:
	plugin_api_function("on_start")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	plugin_api_function("on_update")

func action_1() -> void:
	plugin_api_function("on_custom_action_1")

func action_2() -> void:
	plugin_api_function("on_custom_action_2")

func action_3() -> void:
	plugin_api_function("on_custom_action_3")

func action_4() -> void:
	plugin_api_function("on_custom_action_4")

## Creates trigger, if it does not exist
func spawn_trigger(shape: TriggerShape, function: String, size: float, collider_rotation: Vector3 = Vector3.ZERO, position_from_center: Vector3 = Vector3.ZERO, height: float = 1.0) -> void:
	if trigger == null:
		Console.print_error("[Plugin system] Triggers are disabled for this puppet.", true)
		return
	if !trigger.is_empty():
		Console.print_error("[Plugin system] Trigger already created! Currently, only one trigger per class is supported")
		return
	var area_3d: Area3D = Area3D.new()
	area_3d.collision_layer = 15
	area_3d.collision_mask = 15
	add_child(area_3d)
	area_3d.position = position_from_center
	var collision_shape: CollisionShape3D = CollisionShape3D.new()
	match shape:
		TriggerShape.SPHERE:
			collision_shape.shape = SphereShape3D.new()
			collision_shape.shape.radius = size
		TriggerShape.BOX:
			collision_shape.shape = BoxShape3D.new()
			collision_shape.shape.size = Vector3(size, size, size)
		TriggerShape.CAPSULE:
			collision_shape.shape = CapsuleShape3D.new()
			collision_shape.shape.radius = size
			collision_shape.shape.height = height
		TriggerShape.CYLINDER:
			collision_shape.shape = CylinderShape3D.new()
			collision_shape.shape.radius = size
			collision_shape.shape.height = height
	collision_shape.rotation = collider_rotation
	area_3d.add_child(collision_shape)
	area_3d.body_entered.connect(_on_trigger_body_entered)
	area_3d.body_exited.connect(_on_trigger_body_exited)

func _on_trigger_body_entered(body: Node3D) -> void:
	if body is MovableNpc:
		if body.is_player:
			plugin_api_function("on_player_entered_trigger")
		else:
			plugin_api_function("on_puppet_entered_trigger")

func _on_trigger_body_exited(body: Node3D) -> void:
	if body is MovableNpc:
		if body.is_player:
			plugin_api_function("on_player_exited_trigger")
		else:
			plugin_api_function("on_puppet_exited_trigger")

func on_vision_area_body_entered(body: Node3D):
	if body is MovableNpc:
		for puppet_class in vision_class_detect:
			if body.fraction == puppet_class:
				active_puppets.append(body)
				plugin_api_function("on_player_entered_vision_area")

func on_vision_area_body_exited(body: Node3D):
	if body is MovableNpc:
		if active_puppets.has(body):
			active_puppets.erase(body)
			plugin_api_function("on_player_exited_vision_area")
