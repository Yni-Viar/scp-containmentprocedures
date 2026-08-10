extends BaseSpawner
## Spawns random item, defined by array of paths and Availabilities
## Made by Yni, licensed under MIT License.
class_name ItemSequence

signal item_not_found

## Target item to spawn
@export var items: Dictionary[String, Availability]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if items != null:
		if !items.is_empty():
			var used_spawns: Array[int] = []
			for i in range(128):
				var random_number: int = randi_range(0, items.size() - 1) #get_tree().root.get_node("Game").rng.randi_range(0, items.size() - 1)
				if used_spawns.has(random_number):
					i -= 1
					# Do not let infinite cycle!
					if i < -128:
						break
					continue
				var availability: Availability = items[items.keys()[random_number]]
				# if has chance AND is available in profile, then spawn.
				if availability == 0 || (availability == 1 && !OS.has_feature("Lite")) || (availability == 2 && OS.has_feature("Lite")):
					if !items.keys()[random_number].begins_with("empty"):
						var prefab: Node3D = load(items.keys()[random_number]).instantiate()
						add_child(prefab, true)
					return
				else:
					used_spawns.append(random_number)
					continue
	item_not_found.emit()
