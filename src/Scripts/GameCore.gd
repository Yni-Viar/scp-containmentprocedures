extends Node3D
class_name GameCore
## Game system.
## Made by Yni, licensed under MIT license.


@export var gamedata: GameData
var rng: RandomNumberGenerator = RandomNumberGenerator.new()
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
var mtf_cooldown: float = 35.0:
	set(val):
		mtf_cooldown = val
		if mtf_cooldown <= 0.0:
			$UI/HBoxContainer/CallMtfButton.disabled = false
## Protagonist tracker
var protagonist: MovableNpc


var showable_res: String = ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	RenderingServer.viewport_set_measure_render_time(get_tree().root.get_viewport_rid(), true)
	ci_timer = rng.randf_range(30.0, 32.0)
	if OS.has_feature("Lite"):
		gamedata = load("res://Scripts/GameData/Lite/LiteGame.tres")
		var rooms: Array[MapGenZone] = [load("res://MapGen/Lite/MaintenanceZoneLite.tres"), load("res://MapGen/Lite/ResearchZoneLite.tres"), load("res://MapGen/Lite/PersonnelZoneLite.tres")]
		$FacilityGenerator.rooms = rooms
	else:
		gamedata = load("res://Scripts/GameData/Optional/DefaultGame.tres")
		var rooms: Array[MapGenZone] = [load("res://MapGen/Optional/MaintenanceZone.tres"), load("res://MapGen/Optional/ResearchZone.tres"), load("res://MapGen/Optional/PersonnelZone.tres")]
		$FacilityGenerator.rooms = rooms
	# Choose seed
	$FacilityGenerator.rng = rng
	if map_seed != -1:
		rng.seed = map_seed
		$FacilityGenerator.rng_seed = map_seed
	else:
		rng.randomize()
	$FacilityGenerator.generate_rooms()
	
	# Apply settings
	# Enable or disable glow
	$WorldEnvironment.environment.glow_enabled = Settings.setting_res.glow
	# Enable SSAO in OpenGL only in Godot 4.6
	if RenderingServer.get_current_rendering_method() == "forward_plus" || \
	 (RenderingServer.get_current_rendering_method() == "gl_compatibility" && \
	  Engine.get_version_info()["minor"] >= 6):
		$WorldEnvironment.environment.ssao_enabled = Settings.setting_res.ssao
	$WorldEnvironment.environment.tonemap_mode = Settings.setting_res.tonemapper
	if Settings.setting_res.tonemapper != Environment.TONE_MAPPER_LINEAR || \
	 Settings.setting_res.tonemapper != Environment.TONE_MAPPER_AGX:
		$WorldEnvironment.environment.tonemap_white = 2.0
	else:
		$WorldEnvironment.environment.tonemap_white = 1.0
	## Enable/disable reflection probes (cubemap)
	for node in get_tree().get_nodes_in_group("ReflectionProbe"):
		if node is ReflectionProbe:
			if !Settings.setting_res.reflection_probe: # || Settings.setting_res.ssr:
				node.hide()
			else:
				node.show()
	
	if Settings.setting_res.lighting != SettingsResource.Lighting.LIGHTMAP:
		if Settings.setting_res.lighting == SettingsResource.Lighting.NONE:
			$WorldEnvironment.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
			$WorldEnvironment.environment.ambient_light_color = Color(0.5, 0.5, 0.5)
		for node in get_tree().get_nodes_in_group("Lightmap"):
			if node is LightmapGI:
				node.queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !$GameOverTimer.is_stopped():
		$UI/TimeToLeft.text = tr("SECONDS_LEFT") + " " + str(ceili($GameOverTimer.time_left))
	if ci_ready:
		if ci_probability == 1:
			ci_timer -= delta
			if ci_timer < 0:
				spawn_wave_entity(1)
				# Disable Chaos wave if they were already spawned (5.5.0 feature)
				ci_probability = 0
		if mtf_cooldown > 0.0:
			mtf_cooldown -= delta
	if time_limited && protagonist != null:
		# Hunger and thirst mechanic
		protagonist.health_manage(-delta * 0.25, 2)
		protagonist.health_manage(-delta * 0.1875, 3)


func _on_facility_generator_generated() -> void:
	# Spawn surface zone
	var sz: Node3D = load("res://Assets/Rooms/sublevels/External/subl_sz.tscn").instantiate()
	sz.position.y = 256.0
	add_child(sz, true)
	
	spawn_offices("res://Assets/Rooms/ScientistsRooms/Default.tscn", "OfficeSpawn")
	
	spawn_player()
	spawn_puppets()
	
	if time_limited && !Settings.setting_res.zen_mode:
		$GameOverTimer.start()
	
	$FoundationTask.initialize()
	$UI._on_foundation_task_task_done()
	
	# Spawn SCP-347 agent, if there is a task
	#if get_node("FoundationTask").has_task("task_347"):
		#spawn_wave_entity(2)
	
	await get_tree().create_timer(5.0).timeout
	$LoadingScreen.call_deferred("hide")
	if ci_probability < 0:
		# Disable CI event, if hard mode, safe mode, or if you are lucky to get in 3/4
		if !time_limited && !Settings.setting_res.zen_mode && rng.randi_range(0, 3) == 1:
			ci_probability = 1
		else:
			ci_probability = 0
	ci_ready = true
	
## Spawns player-protagonist
func spawn_player():
	# Player and allies
	protagonist = load("res://PlayerScript/NPCBase.tscn").instantiate()
	protagonist.puppet_class = gamedata.player_class[0]
	protagonist.is_player = true
	
	var spawns = get_tree().get_nodes_in_group("PlayerSpawn")
	var selected_spawn: Marker3D = spawns[rng.randi_range(0, spawns.size() - 1)]
	protagonist.global_position = selected_spawn.global_position
	$NPCs.add_child(protagonist)
	$StaticPlayer.target_puppet_path = protagonist.get_path()

## Start-round spawn
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

## Spawns wave entities
func spawn_wave_entity(wave_type: int):
	var how_much_spawn: int = -1
	match wave_type:
		0: # Mobile Task Force
			how_much_spawn = 3
		1: # Chaos Insurgency Agent
			how_much_spawn = 1
		#2: # Agent for SCP-347
			#how_much_spawn = 1
	var spawn = get_tree().get_first_node_in_group("WaveSpawn")
	if spawn != null:
		if OS.get_name() != "Web":
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
				#2:
					#wavenpc.puppet_class = gamedata.wave_puppet_classes[2]
			spawn.get_child(i).add_child(wavenpc)
		for i in range(how_much_spawn):
			for node in spawn.get_child(i).get_children():
				if node is not MovableNpc:
					node.queue_free()

## Despawns wave VFX.
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

## Personnel office spawner
func spawn_offices(default_office_path: String, spawn_group: String):
	var all_available_offices: Array[Node] = get_tree().get_nodes_in_group(spawn_group)
	all_available_offices.shuffle()
	for i in range(get_tree().get_node_count_in_group(spawn_group)):
		if i < gamedata.custom_scientists_offices.size():
			var office: Node3D = gamedata.custom_scientists_offices[i].instantiate()
			all_available_offices[i].add_child(office)
		else:
			var office: Node3D = load(default_office_path).instantiate()
			all_available_offices[i].add_child(office)

## Game end
func finish_game(good_end: bool, reason: String):
	$UI/Condition/ConditionLabel.text = "GAME_WIN" if good_end else "GAME_OVER"
	$UI/Condition/ReasonLabel.text = reason
	$AnimationPlayer.play("condition_open")
	$GameOverTimer.stop()

## Cutscene animation
func cutscene_anim(reverse: bool = false):
	if reverse:
		$AnimationPlayer.play_backwards("cutscene")
	else:
		$AnimationPlayer.play("cutscene")

## Dialogue system from 7.0 and earlier.
## @deprecated This function may be removed in 9.0, please, use advanced_dialogue([text]) as replacement.
func dialogue(text: String):
	advanced_dialogue([text])

## Dialogue system (used in 067, 1223, 2028 and 2471)
func advanced_dialogue(random_text: Array, command_after: CommandResource = null):
	$UI/Dialogue.text = random_text[rng.randi_range(0, random_text.size() - 1)]
	for i in $UI/Dialogue.text.length():
		$UI/Dialogue.visible_characters = i
		await get_tree().physics_frame
	$UI/Dialogue.visible_characters = -1
	if command_after != null:
		protagonist._call_function(command_after.action_node_path, command_after.action_method_name, command_after.action_args)
	await get_tree().create_timer(2.0).timeout
	$UI/Dialogue.text = ""

## Shows image (6.0 version)
## @deprecated This function may be removed in 9.0, please use show_image function
func showable(resource_path: String):
	show_image([resource_path])

## Shows random images (currently used for 067 and 1223)
## If specified, a command will be done after some seconds (if showed)
func show_image(images: Array, command_after: CommandResource = null, timer: float = 0.0):
	if (images != null && images.size() > 0):
		var resource_path: String = images[rng.randi_range(0, images.size() - 1)]
		if $UI/Showable.visible:
			$UI/Showable.hide()
			showable_res = ""
		elif resource_path != showable_res && (resource_path.begins_with("res://") || resource_path.begins_with("user://")):
			$UI/Showable.show()
			var res = load(resource_path)
			if res is Texture2D:
				$UI/Showable.texture = res
				showable_res = resource_path
				if command_after != null:
					if timer > 0.375:
						await get_tree().create_timer(timer).timeout
					protagonist._call_function(command_after.action_node_path, command_after.action_method_name, command_after.action_args)
	else:
		$UI/Showable.hide()
		showable_res = ""

## Calls MTF.
func call_mtf():
	if get_node("FoundationTask").has_task("task_ci") && mtf_cooldown <= 0.0:
		spawn_wave_entity(0)
		mtf_cooldown = 50.0


func _on_game_over_timer_timeout() -> void:
	finish_game(false, "GAME_OVER_3")
