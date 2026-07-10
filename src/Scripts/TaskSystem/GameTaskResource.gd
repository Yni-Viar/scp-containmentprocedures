extends Resource
## Created by Yni, licensed under dual license: for SCP content - GPL 3, for non-SCP - MIT License
class_name GameTaskResource

## Internal name
@export var internal_name: String = ""
## Name, that will be displayed
@export var public_name: String = ""
## Required groups
@export var required_groups: Array[String] = []
## Sub tasks, if exist.
@export var sub_tasks: Array[GameTaskResource] = []
## Time to complete (or has no limit if value below 3.125
@export var time_to_complete: float = 0.0
## Resulting event
@export var resulting_event: GameTaskManager.SpecialEvent = GameTaskManager.SpecialEvent.NONE
