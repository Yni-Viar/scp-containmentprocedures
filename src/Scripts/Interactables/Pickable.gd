extends RigidBody3D
## Created by Yni, licensed under MIT License
class_name Pickable

## Item ID to pick
@export var item_id: int
@export_group("Automatic - do not touch")
## Leave this FALSE in inspector - needed only for anti-dupe
@export var picked: bool = false
## Leave this empty in inspector - needed for SCP-261 food box to function
@export var item_properties: Array[String] = []
