extends Node3D
class_name GameCore
## Game system.
## Made by Yni, licensed under MIT license.


@export var gamedata: GameData
var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var player: Node3D
## It is actually how many generators are left
var activated_generators: int = 0
## Presets for game ##
var map_seed: int = -1
## Possibility to spawn Chaos Insurgency
var ci_probability: int = -1
## Time limit enabled
var time_limited: bool = true
## End presets for game ##

## Enemy spawn timer
var ci_timer: float = 20.0
## Are Chaos Insurgency ready to spawn (automatically set after 15 seconds)
var ci_ready: bool = false
## MTF call cooldown
var mtf_cooldown: float = 10.0
## Protagonist tracker
var protagonist: MovableNpc
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if time_limited:
		$GameOverTimer.start()
	# Choose seed
	if map_seed >= 0:
		$FacilityGenerator.rng_seed = map_seed
	$FacilityGenerator.generate_rooms()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !$GameOverTimer.is_stopped():
		$UI/TimeToLeft.text = tr("SECONDS_LEFT") + " " + str(ceili($GameOverTimer.time_left))
	if protagonist != null:
		get_node("StaticPlayer").global_position = protagonist.global_position + Vector3(0, 3, 0)
	if ci_probability == 1 && ci_ready:
		ci_timer -= delta
		if ci_timer < 0:
			spawn_wave_entity(1)
			get_node("FoundationTask").trigger_event(2, load("res://Scripts/TaskSystem/Tasks/CIEmergencyTask.tres"))
			ci_timer = 120.0
		mtf_cooldown -= delta


func _on_facility_generator_generated() -> void:
	spawn_player()
	spawn_puppets()
	$FoundationTask.initialize()
	$UI._on_foundation_task_task_done()
	if get_node("FoundationTask").has_task("task_347"):
		spawn_wave_entity(0)
	await get_tree().create_timer(15.0).timeout
	if ci_probability < 0:
		ci_probability = rng.randi_range(0, 1)
	ci_ready = true

func spawn_player():
	# Player and allies
	protagonist = load("res://PlayerScript/NPCBase.tscn").instantiate()
	protagonist.puppet_class = gamedata.player_class[0]
	protagonist.is_player = true
	var spawns = get_tree().get_nodes_in_group("PlayerSpawn")
	var selected_spawn: Marker3D = spawns[rng.randi_range(0, spawns.size() - 1)]
	selected_spawn.add_child(protagonist)
	$StaticPlayer.target_puppet_path = protagonist.get_path()


func spawn_puppets():
	for puppet_res in gamedata.puppet_classes:
		var spawn_point_group = get_tree().get_nodes_in_group(puppet_res.spawn_point_group)
		var used_spawns: Array[int] = []
		if get_tree().get_nodes_in_group(puppet_res.spawn_point_group).size() == 0:
			continue
		for i in range(puppet_res.initial_amount):
			if i > spawn_point_group.size() - 1:
				break
			var random_number: int = rng.randi_range(0, spawn_point_group.size() - 1)
			if used_spawns.has(random_number):
				continue
			var npc: MovableNpc = load("res://PlayerScript/NPCBase.tscn").instantiate()
			npc.puppet_class = puppet_res
			npc.position = spawn_point_group[random_number].global_position
			$NPCs.add_child(npc)
			used_spawns.append(random_number)

## Spawns enemy entities
func spawn_wave_entity(wave_type: int):
	var how_much_spawn: int = -1
	match wave_type:
		0: # Mobile Task Force
			how_much_spawn = 3
		1: # Chaos Insurgency
			how_much_spawn = rng.randi_range(2, 3)
	var spawn = get_tree().get_first_node_in_group("WaveSpawn")
	for i in range(how_much_spawn):
		var vfxspawn = load("res://Assets/VFX/spawnvfx.tscn").instantiate()
		spawn.get_child(i).add_child(vfxspawn)
	await get_tree().create_timer(1.0).timeout
	for i in range(how_much_spawn):
		var wavenpc: MovableNpc = load("res://PlayerScript/NPCBase.tscn").instantiate()
		match wave_type:
			0: # Mobile Task Force
				wavenpc.puppet_class = gamedata.wave_puppet_classes[0]
				wavenpc.add_to_group("MobileTaskForce")
			1: # Chaos Insurgency
				wavenpc.puppet_class = gamedata.wave_puppet_classes[1]
				wavenpc.add_to_group("ChaosInsurgency")
		spawn.get_child(i).add_child(wavenpc)
	for i in range(how_much_spawn):
		for node in spawn.get_child(i).get_children():
			if node is not MovableNpc:
				node.queue_free()

func despawn_wave(wave_type: int):
	match wave_type:
		0:
			for node in get_tree().get_nodes_in_group("MobileTaskForce"):
				var vfxspawn = load("res://Assets/VFX/spawnvfx.tscn").instantiate()
				node.add_child(vfxspawn)
				node.queue_free()
		1:
			for node in get_tree().get_nodes_in_group("ChaosInsurgency"):
				var vfxspawn = load("res://Assets/VFX/spawnvfx.tscn").instantiate()
				node.add_child(vfxspawn)
				node.queue_free()

## Game end
func finish_game(good_end: bool, reason: String):
	$UI/Condition/ConditionLabel.text = "GAME_WIN" if good_end else "GAME_OVER"
	$UI/Condition.show()
	$UI/Condition/ReasonLabel.text = reason
	$GameOverTimer.stop()
	Settings.set_pause_subtree(true)

func call_mtf():
	if get_node("FoundationTask").has_task("task_ci") && mtf_cooldown <= 0.0:
		spawn_wave_entity(0)
		mtf_cooldown = 20.0


func _on_game_over_timer_timeout() -> void:
	finish_game(false, "GAME_OVER_3")
