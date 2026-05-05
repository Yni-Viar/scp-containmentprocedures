extends Resource
## Made by Yni, licensed under CC0.
class_name Item

## 0 / NORMAL - nothing will happen after item is used.
## 1 / ONE_TIME - item will destroy after using
## 2 / ONE_TIME_DROP - item will be dropped after using.
enum Usage {NORMAL, ONE_TIME, ONE_TIME_DROP}

## Item ID
@export var id: int = 0
## Item name
@export var name: String = ""
## Item texture
@export var texture_tiled: Texture2D = null
## Path to a pickable
@export var pickable_path: String = ""
## Unused
@export var pickup_sound_path: String = ""
## Tile size
@export var size: Vector2i = Vector2i.ZERO
## Usage (see enum comments)
@export var usage: Usage = Usage.NORMAL
@export_group("Command")
## Which node to trigger function
@export var action_node_path: String = ""
## Method name to call
@export var action_method_name: String = ""
## Arguments
@export var action_args: Array = []
@export_group("Status effects")
## Name of status effect to apply
@export var status_effect: String = ""
## Strength of status effect (if supported). Note, that 0.0 cancels status effect.
@export var status_effect_strength: float = 1.0
## Status effect duration, in seconds. Note, that values below 0.325 are infinite duration.
@export var status_effect_duration: float = 0.0
## Can be destroyed through inventory
@export var status_effect_destroyable: bool = true
## Status effect will be applied, after status_effect_timer seconds. Note, that values below 0.325 will apply status effect instantly.
@export var status_effect_timer: float = 0.0
@export_group("SCP-914")
@export var upgrade_rough: Array[int] = []
@export var upgrade_coarse: Array[int] = []
@export var upgrade_one_to_one: Array[int] = []
@export var upgrade_fine: Array[int] = []
@export var upgrade_very_fine: Array[int] = []
@export_group("Custom properties")
## Custom properties of the item, such as SCP-261 different food.
@export var custom_properties: Array[String] = []
