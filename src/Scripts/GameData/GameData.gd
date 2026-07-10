extends Resource
## Class data.
## Made by Yni, licensed under MIT license.
class_name GameData
## Puppet class, that will be used by the player
@export var player_class: Array[PuppetClass] = []
## Puppet class
@export var puppet_classes: Array[PuppetClass] = []
## Legacy (pre-10.0) tasks.
@export var tasks: Array[GameTaskResource] = []
## All items.
@export var items: Array[Item] = []
## Custom Scientist's offices (available since v7.0)
@export var custom_scientists_offices: Array[PackedScene] = []
## Status Effects
@export var status_effects: Dictionary[String, StatusEffect] = {}
