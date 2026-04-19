extends BaseSpawner
## Spawn item by a chance
## Made by Yni, licensed under MIT License.
class_name ItemSpawner


## Target item to spawn
@export var item: PackedScene
## Chance to spawn
@export_range(0.0, 1.0, 0.0001) var chance: float = 0.33
@export var availability: Availability = Availability.ALL

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if get_tree().root.get_node("Game").rng.randf_range(0.0, 1.0) < chance && item != null:
		# if has chance AND is available in profile, then spawn.
		if availability == Availability.ALL || (availability == Availability.FULL && !OS.has_feature("Lite")) || (availability == Availability.LITE && OS.has_feature("Lite")):
			var prefab: Node3D = item.instantiate()
			add_child(prefab)
