extends BasePuppetScript
## In future, it will be base for near-all classes, except non-modificable ones.
## Made by Yni, licensed under MIT license.
class_name SkinnablePuppetScript

## If true, makes the entities of `single_type_group_name` use the same id.
## Useful for entities, that should be same in the round.
@export var single_type_per_group: bool = false
## Group for single typed entities (see `single_type_per_group` for explanation)
@export var single_type_group_name: String = ""
## It is recommended to leave it with default value
## This parameter determines if specific puppet will be spawned or will be randomized.
@export var default_puppet_to_spawn: int = -1
## All available puppet variations
@export var available_puppets: Dictionary[String, BaseSpawner.Availability] = {}
@export_group("GLTF loader")
## Enables GLTF loading
## /!\ Use only if the puppet has no animations, or does not use AnimationTree
## Better works with single_type_per_group = true
@export var enable_gltf_loading: bool = false
## File prefix, separated by _ .
## Also used by `default_class_presets_gltf_extension`
@export var gltf_file_prefix: String = ""
## File suffix, separated by _ , just before extension
## Not necessary, unlike prefix
@export var gltf_file_suffix: String = ""
## Path to find GLTF models
@export var gltf_path_to_find: String = ""
## Required animations to function
#@export var gltf_required_animations: Array[String] = []

@export_group("Technical - do not touch")
## Technical puppet ID
@export var selected_puppet: int = -1
## Current puppet's node path
@export var puppet_node: Node3D
## Check if single type had spawned.
@export var single_type_spawned: bool = false
## Default index for single puppets
static var default_class_presets: Dictionary[String, int]
## GLTF model cache
static var gltf_cache: Dictionary[String, PackedScene] = {}
## Default GLTF file name for single puppets (if GLTF is used)
static var default_class_presets_gltf_extension: Dictionary[String, String]

# Called when the node enters the scene tree for the first time.
func on_start() -> void:
	# Checking for mods
	if enable_gltf_loading && OS.get_name() != "Web" && gltf_file_prefix != null:
		var suffix_exists: bool = false
		# Check if file does not exist
		if gltf_path_to_find == null:
			printerr("Could not find path of GLTF")
			enable_gltf_loading = false
			_set_up_puppet()
			return
		if gltf_path_to_find.is_empty():
			printerr("Could not find path of GLTF")
			enable_gltf_loading = false
			_set_up_puppet()
			return
		if gltf_file_suffix != null:
			if !gltf_file_suffix.is_empty():
				suffix_exists = true
		if !DirAccess.dir_exists_absolute("user://mods/puppets/" + gltf_path_to_find):
			DirAccess.make_dir_recursive_absolute("user://mods/puppets/" + gltf_path_to_find)
		# Add all GLB files
		var dir: DirAccess = DirAccess.open("user://mods/puppets/" + gltf_path_to_find)
		for file in dir.get_files():
			if file.get_extension() == "glb" && file.begins_with(gltf_file_prefix):
				if suffix_exists && !file.get_slice(".", 0).ends_with(gltf_file_suffix):
					continue
				
				# Load GLTF
				gltf_cache[file] = Settings.load_gltf("user://mods/puppets/" + gltf_path_to_find + "/" + file)
				if gltf_cache[file] == null:
					continue
				# If has animation - check if all required animations exists,
				# else - remove this GLTF from loading
				#if gltf_cache[file].get_node_or_null("AnimationPlayer") != null:
					#var has_all_animations: bool = true
					#for anim in gltf_required_animations:
						#if !gltf_cache[file].get_node("AnimationPlayer").has_animation(anim):
							#has_all_animations = false
					#if !has_all_animations:
						#gltf_cache[file].queue_free()
						#continue
				# If GLTF exists - add it to available puppets list
				available_puppets[file] = BaseSpawner.Availability.ALL
	_set_up_puppet()

## Try to spawn puppet after initial loading
func _set_up_puppet() -> void:
	if default_puppet_to_spawn < 0:
		if single_type_per_group && get_tree().has_group(single_type_group_name):
			selected_puppet = get_static_preset()
			if enable_gltf_loading && default_class_presets_gltf_extension.has(gltf_file_prefix):
				assign_puppet_gltf()
			else:
				get_tree().call_group(single_type_group_name, "assign_puppet", selected_puppet)
		else:
			assign_puppet()
	else:
		assign_puppet(default_puppet_to_spawn)

func on_spawned() -> void:
	pass

## Gets (or sets, if not existing) static presets.
func get_static_preset() -> int:
	if !default_class_presets.has(single_type_group_name):
		var idx: int = get_tree().root.get_node("Game").rng.randi_range(0, available_puppets.size() - 1)
		for i in range(127):
			if check_availability(idx):
				break
			idx = get_tree().root.get_node("Game").rng.randi_range(0, available_puppets.size() - 1)
		default_class_presets[single_type_group_name] = idx
		# If file name is GLTF - save gltf file name without
		# prefix and suffix
		if enable_gltf_loading && available_puppets.keys()[idx].get_extension() == "glb":
			var keyword: String = available_puppets.keys()[idx].get_slice(".", 0).trim_suffix("_" + gltf_file_suffix).trim_prefix(gltf_file_prefix + "_")
			if !default_class_presets_gltf_extension.has(gltf_file_prefix):
				default_class_presets_gltf_extension[gltf_file_prefix] = keyword
	return default_class_presets[single_type_group_name]

## Assign a puppet variation to the puppet script
## Has optional parameter, which can force specific
func assign_puppet(idx: int = -1) -> void:
	if puppet_node != null:
		puppet_node.queue_free()
	if available_puppets != null:
		if !available_puppets.is_empty():
			if idx >= 0 && idx < available_puppets.size():
				if check_availability(idx):
					_initiate_puppet(idx)
					return
				else:
					get_parent().get_parent().health_manage(-16777216)
					return
			
			var used_spawns: Array[int] = []
			for i in range(128):
				var random_number: int = get_tree().root.get_node("Game").rng.randi_range(0, available_puppets.size() - 1)
				if used_spawns.has(random_number):
					i -= 1
					# Do not let infinite cycle!
					if i < -128:
						break
					continue
				
				if check_availability(random_number):
					_initiate_puppet(random_number)
					return
				else:
					used_spawns.append(random_number)
					continue
	get_parent().get_parent().health_manage(-16777216)

func assign_puppet_gltf() -> void:
	var prefab: Node3D
	if gltf_file_suffix != null && !gltf_file_suffix.is_empty():
		if !gltf_cache.has(gltf_file_prefix + "_" + default_class_presets_gltf_extension[gltf_file_prefix] + "_" + gltf_file_suffix + ".glb"):
			get_parent().get_parent().health_manage(-16777216)
			return
		prefab = gltf_cache[gltf_file_prefix + "_" + default_class_presets_gltf_extension[gltf_file_prefix] + "_" + gltf_file_suffix + ".glb"].instantiate()
	else:
		if !gltf_cache.has(gltf_file_prefix + "_" + default_class_presets_gltf_extension[gltf_file_prefix] + ".glb"):
			get_parent().get_parent().health_manage(-16777216)
			return
		prefab = gltf_cache[gltf_file_prefix + "_" + default_class_presets_gltf_extension[gltf_file_prefix] + ".glb"].instantiate()
	add_child(prefab)
	puppet_node = prefab
	on_spawned()

## if has chance AND is available in profile, then return true else false.
func check_availability(idx: int) -> bool:
	var availability: BaseSpawner.Availability = available_puppets[available_puppets.keys()[idx]]
	
	if availability == 0 || (availability == 1 && !OS.has_feature("Lite")) || (availability == 2 && OS.has_feature("Lite")):
		return true
	else:
		return false

## Technical function - spawns puppet
func _initiate_puppet(idx: int):
	if !available_puppets.keys()[idx].begins_with("empty"):
		var prefab: Node3D = load(available_puppets.keys()[idx]).instantiate()
		add_child(prefab)
		selected_puppet = idx
		puppet_node = prefab
		on_spawned()

func _exit_tree() -> void:
	if !gltf_cache.is_empty() && get_tree().get_node_count_in_group("CustomizablePuppet") == 1:
		gltf_cache.clear()
		default_class_presets_gltf_extension.clear()
	if get_tree().get_node_count_in_group("SinglePuppet") == 1:
		default_class_presets.clear()
