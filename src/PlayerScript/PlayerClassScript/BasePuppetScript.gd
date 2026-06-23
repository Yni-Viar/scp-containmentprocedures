extends Node3D
## Made by Yni, licensed under CC0.
class_name BasePuppetScript


## Armature name
@export var armature_name: String = "HumanRig"
enum States {IDLE, WALKING, RUNNING, SPECIAL1, SPECIAL2, SPECIAL3, SPECIAL4}
@export var state: States = States.IDLE

## If true, NPC will scan other NPCs via Area
@export var enable_vision_scan: bool = false
@export var vision_class_detect: Array[int] = [0]

#@export_group("Festive settings")
### Set false to disable festive decorations.
#@export var fixed_prefab: bool = false
### Format: NodePath: [[material_index, material], ...]
#@export var christmas_suits: Dictionary[NodePath, Array]
### Format: NodePath: [[material_index, material], ...]
#@export var halloween_suits: Dictionary[NodePath, Array]
@export_group("DO NOT TOUCH")
@export var active_puppets: Array[Node3D] = []

var rng: RandomNumberGenerator = RandomNumberGenerator.new()


func _ready() -> void:
	if enable_vision_scan:
		get_parent().get_parent().get_node("VisionArea").connect("body_entered", on_vision_area_body_entered)
		get_parent().get_parent().get_node("VisionArea").connect("body_exited", on_vision_area_body_exited)
	
	#if fixed_prefab:
		##Festive decorations
		#match Settings.current_season:
			#Settings.Season.CHRISTMAS:
				#for node_path in christmas_suits:
					#for i in range(christmas_suits[node_path].size()):
						#get_node(node_path).set_surface_override_material(christmas_suits[node_path][i][0], christmas_suits[node_path][i][1])
			#Settings.Season.HALLOWEEN:
				#for node_path in halloween_suits:
					#for i in range(halloween_suits[node_path].size()):
						#get_node(node_path).set_surface_override_material(halloween_suits[node_path][i][0], halloween_suits[node_path][i][1])
	on_start()

func on_start():
	pass

func on_vision_area_body_entered(body: Node3D):
	if body is MovableNpc:
		for puppet_class in vision_class_detect:
			if body.fraction == puppet_class:
				active_puppets.append(body)

func on_vision_area_body_exited(body: Node3D):
	if body is MovableNpc:
		if active_puppets.has(body):
			active_puppets.erase(body)

func special_action():
	pass

## Effect start callback
func effect_manager_start(effect: String, strength: float):
	pass

## Effect process callback
func effect_manager_update(effect: String, strength: float):
	pass

## Effect destroy callback
func effect_manager_destroy(effect: String, strength: float):
	pass
