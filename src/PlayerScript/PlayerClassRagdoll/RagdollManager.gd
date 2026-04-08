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
@export var seconds_before_despawn: float = 30.0
@export_group("Festive settings")
## Set false to disable festive decorations.
@export var fixed_prefab: bool = false
## Format: NodePath: [[material_index, material], ...]
@export var christmas_suits: Dictionary[NodePath, Array]
## Format: NodePath: [[material_index, material], ...]
@export var halloween_suits: Dictionary[NodePath, Array]

var update_timer: float = 1.0

# Called when the node enters the scene tree for the first time.
func _ready():
	if fixed_prefab:
		# Festive
		match Settings.current_season:
			Settings.Season.CHRISTMAS:
				for node_path in christmas_suits:
					for i in range(christmas_suits[node_path].size()):
						get_node(node_path).set_surface_override_material(christmas_suits[node_path][i][0], christmas_suits[node_path][i][1])
			Settings.Season.HALLOWEEN:
				for node_path in halloween_suits:
					for i in range(halloween_suits[node_path].size()):
						get_node(node_path).set_surface_override_material(halloween_suits[node_path][i][0], halloween_suits[node_path][i][1])
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
