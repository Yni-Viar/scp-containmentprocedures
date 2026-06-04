extends BasePuppetScript
## In future, it will be base for near-all classes, except non-modificable ones.
## Made by Yni, licensed under MIT license.
class_name SkinnableTestPuppetScript

## It is recommended to leave it with default value
## This paramterer determines if specific puppet will be spawned or will be randomized.
@export var default_puppet_to_spawn: int = -1
## All available puppet variations
@export var available_puppets: Dictionary[String, BaseSpawner.Availability] = {}
@export_group("Technical - do not touch")
## Technical puppet ID
@export var selected_puppet: int = -1
## Current puppet's node path
@export var puppet_node: Node3D

# Called when the node enters the scene tree for the first time.
func on_start() -> void:
	if default_puppet_to_spawn < 0:
		assign_puppet()
	else:
		assign_puppet(default_puppet_to_spawn)

func on_spawned() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

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
					return
			
			var used_spawns: Array[int] = []
			for i in range(128):
				var random_number: int = randi_range(0, available_puppets.size() - 1)
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
