extends CharacterBody3D
class_name MovableNpc
## Mostly made by Yni, licensed under MIT license.
## ------------------------------------------
## Contains third-party code from Godot demos. 
## Copyright (c) 2014-present Godot Engine contributors.
## Copyright (c) 2007-2014 Juan Linietsky, Ariel Manzur.
## Licensed under MIT License.
## ------------------------------------------
## Interactable NPC.

## Generic wander is MovableNpc wander implementation
## Special wander is limited wander - just moving from point to point.
## If they leave containment chamber, wandering system will be switched to generic wander.
## AI wander cannot be selected by-default, as it requires AI to be enabled.
enum WanderingSystem {NONE, GENERIC_WANDER, LIMITED_WANDER, AI_WANDER}


## Speed
@export var character_speed: float = 10.0

## Move sounds toggle
@export var move_sounds_enabled: bool = false
## Walk sounds
@export var footstep_sounds: Array[String]
## Sprint sounds
@export var sprint_sounds: Array[String]

## Applies height bugfix
@export var apply_height_bugfix: bool = false
## How much the height of character will be decreased
@export var height_bugfix_amount: float = -0.04
## Is the character on moving platform (a workaround, since without this the NPC flies away)
@export var platform_moving: bool = false

@export var puppet_class: PuppetClass
## See PuppetResource description
@export var fraction: int
@export var health: Array[float] = []
@export var current_health: Array[float] = []
@export var movement_freeze: bool = false
@export var money: Dictionary[String, int] = {}
@export var immortal: bool = false
@export var keycards: Array[int] = []

@export var wandering_system: WanderingSystem = WanderingSystem.NONE:
	set(val):
		wandering = (val != WanderingSystem.NONE)
		wandering_system = val
@export var special_wandering_group: String = ""

## The main wandering switch
@export var wandering: bool = false:
	set(val):
		if val:
			idle = true
		else:
			idle = false
		wandering = val
## How many npc will rotate
var wandering_rotator: int
## Walking/rotating toggle
var wander_action: bool = false
## On which degree npc will wander
var wandering_destination: int
## Only when navigation map is ready, npc will wander
var wandering_ready: bool = false
## Special wandering timer
var special_wandering_timer: float = 0.0
## Only when idle NPC will wander
var idle: bool = false

## Interval between re-calling target follow (only when they follow)
var follow_update_timer: float = 1.0
## Follow target. If is valid path (BEGINNING WITH /root/ !), they will look at target and follow.
var follow_target: String = "":
	set(val):
		if !val.is_empty():
			wandering = false
			if get_node_or_null(val) == null:
				follow_target = ""
				## New Godot 4.4 feature - the NPC will actually look at player when following them.
				#get_node(str(skeleton_path) + "/LookAtModifier3D").target_node = NodePath(val + "/LookAtTarget")
			#else:
				#get_node(str(skeleton_path) + "/LookAtModifier3D").target_node = ""
		else:
			wandering = wandering_system != WanderingSystem.NONE
			#get_node(str(skeleton_path) + "/LookAtModifier3D").target_node = ""
		follow_target = val
## A workaround, where NPC cannot cross by NavigationLink, when something with navigation will move.
var prev_offset: PackedVector3Array = [Vector3.ONE, Vector3.ONE]
## A check for bugfix height only once.
var height_bugfix_applied: bool = false
var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var spawn_on_start: bool = true
## Check if is a player.
var is_player: bool = false
# Comment this these string, and you'll partly revert to SCP: Cont Pr. 1.0 optimization
var optimizator_paused: bool = true

var puppet_mesh: BasePuppetScript

## AI variables
## Make Variant at first because of legal uncertainity
var nn
var time_alive: float = 0.0
var nn_iterator: int = 3
var nn_current_item: Node3D

@onready var walk_sounds = $WalkSounds
# Begin Godot Demo code (MIT License)
@onready var _nav_agent := $NavigationAgent3D as NavigationAgent3D

func _ready() -> void:
	#state = State.IDLE
	puppet_mesh = puppet_class.prefab.instantiate()
	fraction = puppet_class.fraction
	health = puppet_class.health
	character_speed = puppet_class.speed
	wandering_system = int(puppet_class.wandering_system) as WanderingSystem
	special_wandering_group = puppet_class.special_wandering_group
	spawn_on_start = puppet_class.spawn_on_start
	keycards = puppet_class.keycards
	_nav_agent.avoidance_enabled = puppet_class.enable_avoidance
	_nav_agent.navigation_layers = puppet_class.puppet_navigation_layers
	current_health = health.duplicate()
	wandering_rotator = rng.randi_range(-15, 15)
	for item_id in puppet_class.start_items:
		$UI/Inventory/Inventory.add_item(item_id)
	money = puppet_class.start_money
	$PlayerModel.add_child(puppet_mesh)
	
	if spawn_on_start:
		NavigationServer3D.map_changed.connect(on_map_updated)
	else:
		wandering_ready = true
	
	if !Settings.feature_legality_checker("no_neural_ai") && \
	   Settings.setting_res.ai_enabled && !is_player && puppet_class.enable_advanced_ai:
		nn = NeuralNetwork.new(21, 10, 1) as NeuralNetwork
		for additional_raycast in $NNRay.get_children():
			nn.raycasts.append(additional_raycast)
		if wandering_system != WanderingSystem.NONE:
			wandering_system = WanderingSystem.AI_WANDER
	else:
		$NNRay.queue_free()
	if _nav_agent.avoidance_enabled:
		_nav_agent.velocity_computed.connect(move_pawn)

func _physics_process(delta: float) -> void:
	if $UI/Inventory.visible:
		$UI/Inventory/Money.text = ""
		for m in money:
			$UI/Inventory/Money.text += m + ": " + str(money[m]) + "\n"
	
	# Wander if wandering enabled
	if wandering && idle:
		wander(delta)
	# Stop when platform is moving
	if platform_moving:
		if puppet_mesh != null:
			puppet_mesh.state = puppet_mesh.States.IDLE
		if !is_on_floor():
			velocity += get_gravity() * delta
		if global_position.y < -2048.0:
			health_manage(-16777216, 0, "ERROR!!! SIMULATION BROKEN.")
		move_and_slide()
		return
	# Follow the target, if target is not empty.
	if !follow_target.is_empty():
		if get_node_or_null(follow_target) != null:
			target_follow()
	
	if _nav_agent.is_navigation_finished():
		if puppet_mesh != null:
			if puppet_mesh.state != puppet_mesh.States.IDLE:
				# Strange bug fix (where NPC was always had standing animation (even when moving))
				if global_position.distance_to(_nav_agent.get_final_position()) <= 1:
					puppet_mesh.state = puppet_mesh.States.IDLE
				if wandering:
					idle = true
		return
	
	
	var next_position: Vector3 = _nav_agent.get_next_path_position()
	var offset: Vector3 = next_position - global_position
	if _nav_agent.avoidance_enabled:
		_nav_agent.set_velocity(offset)
	else:
		move_pawn(offset)
	if stop_check(offset):
		if character_speed > 15:
			if puppet_mesh != null:
				puppet_mesh.state = puppet_mesh.States.RUNNING
		else:
			if puppet_mesh != null:
				puppet_mesh.state = puppet_mesh.States.WALKING
		look_at(global_position + Vector3(offset.x, 0, offset.z), Vector3.UP)
	else:
		if puppet_mesh != null:
			puppet_mesh.state = puppet_mesh.States.IDLE
	
	prev_offset[1] = prev_offset[0]
	prev_offset[0] = offset
	if !puppet_class.disable_move_on_slide:
		move_and_slide()

## (Almost) precise check - is player actually moved
func stop_check(offset: Vector3) -> bool:
	var check: Vector3 = Vector3.ZERO
	for prev in prev_offset:
		check += prev
	check /= prev_offset.size()
	if offset.distance_squared_to(check) < 0.001:
		return false
	else:
		return true

func move_pawn(safe_velocity):
	global_position = global_position.move_toward(global_position + safe_velocity, get_physics_process_delta_time() * character_speed)

func set_target_position(target_position: Vector3) -> void:
	_nav_agent.set_target_position(target_position)
	# Change state
	if character_speed > 15:
		if puppet_mesh != null:
			puppet_mesh.state = puppet_mesh.States.RUNNING
	else:
		if puppet_mesh != null:
			puppet_mesh.state = puppet_mesh.States.WALKING
	idle = false
	if apply_height_bugfix && !height_bugfix_applied:
		$Armature.position.y = height_bugfix_amount

# End Godot Demo code (MIT License)
#
#func animation_state_machine(delta: float):
	#match state:
		#State.IDLE:
			#if anim["parameters/state_machine/blend_amount"] - 0.001 >= -1:
				#anim["parameters/state_machine/blend_amount"] = move_toward(anim["parameters/state_machine/blend_amount"], -1, delta * 2.5)
		#State.WALKING:
			#if anim["parameters/state_machine/blend_amount"] + 0.001 <= 0:
				#anim["parameters/state_machine/blend_amount"] = move_toward(anim["parameters/state_machine/blend_amount"], 0, delta * 2.5)
		#State.RUNNING:
			#if anim["parameters/state_machine/blend_amount"] + 0.001 <= 1:
				#anim["parameters/state_machine/blend_amount"] = move_toward(anim["parameters/state_machine/blend_amount"], 1, delta * 2.5)

## Start dialogue with NPC
#func interact(must_talk: bool = false):
	#if can_talk || must_talk:
		#get_tree().root.get_node("Game/PlayerUI").speak(dialogues[current_dialogue][0], dialogues[current_dialogue][1], get_path())

## Health management (health type: 0 is generic health)
func health_manage(health_to_add: float, health_type: int = 0, deplete_reason: String = ""):
	if immortal:
		return
	if health_type >= current_health.size() || health_type >= health.size():
		print("Invalid parameter - wrong health type")
	elif health_type == -1 && puppet_class.fraction == 0:
		health_manage(health_to_add, 0)
		health_manage(health_to_add, 2)
		health_manage(health_to_add, 3)
		return
	if current_health[health_type] + health_to_add <= health[health_type]:
		current_health[health_type] += health_to_add
	else:
		current_health[health_type] = health[health_type]
	if health_type == 1:
		if current_health[1] < health[1]:
			$StatusEffects.apply_status_effect("Frozen", (health[1] - current_health[1]) / health[1], 0.0)
		else:
			$StatusEffects.apply_status_effect("Frozen", 0.0, 0.0)
	
	if current_health[health_type] <= 0:
		if puppet_class.ragdoll_prefab != null:
			var ragdoll: Node3D = puppet_class.ragdoll_prefab.duplicate().instantiate()
			ragdoll.global_position = global_position
			get_parent().add_child(ragdoll)
		# Remove one live
		get_tree().root.get_node("Game").finish_game(false, "GAME_OVER_DIE" if deplete_reason.is_empty() else deplete_reason)
		queue_free()

func _call_function(node_path: String, method_caller: String, amount: Array):
	if method_caller.containsn("OS"):
		printerr("Due to security concerns, this is not allowed")
	match node_path:
		"Game":
			get_tree().root.get_node("Game").callv(method_caller, amount)
		"InGameCommands":
			get_tree().root.get_node("Game/InGameCommands").callv(method_caller, amount)
		"StaticPlayer":
			get_tree().root.get_node("Game/StaticPlayer").callv(method_caller, amount)
		_:
			# First entity from group
			if node_path.begins_with("SingleGroup:") && node_path != "SingleGroup:":
				if get_tree().has_group(node_path.get_slice(":", 1)):
					get_tree().get_first_node_in_group(node_path.get_slice(":", 1)).callv(method_caller, amount)
			# All entities from group
			elif node_path.begins_with("Group:") && node_path != "Group:":
				if get_tree().has_group(node_path.get_slice(":", 1)):
					for entity in get_tree().get_nodes_in_group(node_path.get_slice(":", 1)):
						entity.callv(method_caller, amount)
			else:
				# MovableNpcs and children
				if !node_path.is_empty():
					var safety_circus = node_path.get_slice("/", 0)
					# For safety circus
					get_child(get_node(safety_circus).get_index()).get_node(node_path.trim_prefix(safety_circus + "/")).callv(method_caller, amount)
				else:
					callv(method_caller, amount)

func action_take(index: int):
	if puppet_class.fraction == 0 && get_node_or_null("PlayerModel/Puppet") != null:
		var prefab: Node3D = get_node("PlayerModel/Puppet")
		if prefab is SkinnableHumanPuppetScript:
			prefab.hold_item(index)

## Target follow target position setter.
func target_follow():
	if follow_update_timer > 0:
		follow_update_timer -= get_physics_process_delta_time()
	else:
		if get_node(follow_target).get("movement_freeze") == null:
			follow_update_timer = 1.0
			return
		if !get_node(follow_target).movement_freeze:
			set_target_position(get_node(follow_target).global_position + get_node(follow_target).global_transform.basis.z * 1.5)
		follow_update_timer = 1.0

## MUST be called by moving platform when starts or ends moving.
func on_moving_platform(start: bool):
	platform_moving = start

## Wander implementation
func wander(delta: float):
	match wandering_system:
		WanderingSystem.GENERIC_WANDER:
			# If wander_action, the npc will walk as much as possible, also generate new rotation
			if wander_action:
				if wandering_ready:
					wandering_rotator = rng.randi_range(-15, 15)
					if wandering_rotator == 0:
						wandering_rotator = 1
					set_target_position(NavigationServer3D.map_get_random_point(_nav_agent.get_navigation_map(), 1, true))
					# set the destination with a new rotation degrees
					wandering_destination = roundi(rotation_degrees.y + wandering_rotator)
					wander_action = false
					#wandering_rotator = rng.randi_range(150, 179)
					#wandering_destination = roundi(wrapf(rotation_degrees.y + wandering_rotator, -180, 180))
			elif !optimizator_paused:
				# If the destination is reached - wander
				if roundi(rotation_degrees.y) == wandering_destination:
					wander_action = true
				# var rot: float
				# If a dead end reached, rotate faster
				if wandering_rotator > 120 || wandering_rotator < -120:
					rotate_y(deg_to_rad(20 * delta))
				else:
					rotate_y(deg_to_rad(wandering_rotator * delta * 2))
		WanderingSystem.LIMITED_WANDER:
			# If timer < 0
			if wandering && idle && special_wandering_timer < 0:
				# Walk to random static point
				if get_tree().get_node_count_in_group(special_wandering_group) > 0:
					set_target_position(get_tree().get_nodes_in_group(special_wandering_group)[rng.randi_range(0, get_tree().get_node_count_in_group(special_wandering_group) - 1)].global_position)
					special_wandering_timer = 5.0
				else:
					wandering_system = WanderingSystem.GENERIC_WANDER
			elif !optimizator_paused && idle:
				special_wandering_timer -= delta
		WanderingSystem.AI_WANDER:
			if !Settings.feature_legality_checker("no_neural_ai") && \
			   Settings.setting_res.ai_enabled && !is_player && puppet_class.enable_advanced_ai:
				time_alive += delta
				
				if wandering && special_wandering_timer < 0:
					if idle && (nn_iterator == 3 || nn_current_item == null):
						if get_tree().get_node_count_in_group("Item") > 0:
							nn_current_item = get_tree().get_nodes_in_group("Item")[rng.randi_range(0, get_tree().get_node_count_in_group("Item") - 1)]
							while get_tree().get_nodes_in_group("ImportantItem").has(nn_current_item):
								nn_current_item = get_tree().get_nodes_in_group("Item")[rng.randi_range(0, get_tree().get_node_count_in_group("Item") - 1)]
							set_target_position(nn_current_item.global_position)
							special_wandering_timer = 5.0
							nn_iterator = 0
						else:
							wandering_system = WanderingSystem.GENERIC_WANDER
					elif idle:
						look_at(Vector3(0.0, nn_current_item.global_position.y, 0.0))
						var addition_arg: Array = []
						for raycast in $NNRay.get_children():
							if raycast.get_collision_point().distance_squared_to(nn_current_item.global_position) > 0.5:
								addition_arg = [0.0]
							else:
								addition_arg = [1.0]
								break
						var prediction = nn.get_prediction_from_raycasts(addition_arg)
						if prediction[0] > 0.5 && $RayCastLow.get_collider() is not Pickable:
							$RayCastLow.look_at(nn_current_item.global_position)
							if !get_tree().get_nodes_in_group("ImportantItem").has(nn_current_item):
								$UI/Inventory/Inventory.add_item(nn_current_item.item_id)
								nn_current_item.queue_free()
							nn_iterator = 3
						else:
							nn_iterator += 1
						special_wandering_timer = 1.0
						
				elif !optimizator_paused && idle:
					special_wandering_timer -= delta
			else:
				wandering_system = WanderingSystem.GENERIC_WANDER

func on_map_updated(map: RID):
	wandering_ready = true
	NavigationServer3D.map_changed.disconnect(on_map_updated)
