extends Node3D
## Made by Yni, licensed under CC0.

enum ObjectType {static_prefab, animated, ragdoll}
## Animation to play (only used, when type is ObjectType.animated)
@export var state: String
## Ragdoll type
@export var type: ObjectType = ObjectType.static_prefab
## Armature name (only used, when type is ObjectType.ragdoll)
@export var armature_name: String = "Armature"
## Seconds, before ragdoll despawns
@export var seconds_before_despawn: float = 0.5

var update_timer: float = 1.0

# Called when the node enters the scene tree for the first time.
func _ready():
	update_timer = get_physics_process_delta_time()
	match type:
		ObjectType.animated:
			set_state(state)
	if seconds_before_despawn > 0.05:
		if type == ObjectType.ragdoll:
			get_node(armature_name + "/Skeleton3D/PhysicalBoneSimulator3D").physical_bones_start_simulation()
		await get_tree().create_timer(seconds_before_despawn).timeout
		despawn()
	elif type == ObjectType.ragdoll:
		if OS.get_name() == "Web":
			get_node(armature_name + "/Skeleton3D/PhysicalBoneSimulator3D").physical_bones_stop_simulation()
			return
		else:
			var timer: Timer = Timer.new()
			add_child(timer)
			timer.timeout.connect(check_distance)
			timer.wait_time = 2.0
			timer.start()

func set_state(s):
	if get_node("AnimationPlayer").current_animation != s:
		get_node("AnimationPlayer").play(s)

func despawn():
	if type == ObjectType.ragdoll:
		get_node(armature_name + "/Skeleton3D/PhysicalBoneSimulator3D").physical_bones_stop_simulation()
	queue_free()

func check_distance():
	var ragdoll_simulator: PhysicalBoneSimulator3D = get_node(armature_name + "/Skeleton3D/PhysicalBoneSimulator3D")
	if global_position.distance_to(get_tree().root.get_node("Game/StaticPlayer/Head/Camera3D").global_position) > 64.0 && ragdoll_simulator.is_simulating_physics():
		ragdoll_simulator.physical_bones_stop_simulation()
	elif global_position.distance_to(get_tree().root.get_node("Game/StaticPlayer/Head/Camera3D").global_position) <= 64.0 && !ragdoll_simulator.is_simulating_physics():
		ragdoll_simulator.physical_bones_start_simulation()
