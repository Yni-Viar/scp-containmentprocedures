extends Resource
## Custom commands script (a variation of this script is used by StatusEffects)
## Made by Yni, licensed under MIT License.
class_name CommandResource

## Which node to trigger function
@export var action_node_path: String = ""
## Method name to call
@export var action_method_name: String = ""
## Arguments
@export var action_args: Array = []
@export_group("Dialogue properties")
## Button name
@export var name: String = ""
