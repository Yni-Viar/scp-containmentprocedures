extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GDsh.add_command("add_item", add_item, "Adds item to your inventory")
	GDsh.add_command("spawn_npc", spawn_npc, "Spawns a NPC in front of you")
	GDsh.add_command("add_task", add_task, "Adds task manually, if it is possible to complete.")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

## GDSh command
## Adds item
func add_item(args: Array):
	if args.size() > 0:
		if args[0].is_valid_int():
			if int(args[0]) < get_parent().gamedata.puppet_classes.size() && int(args[0]) > 0:
				get_node(get_parent().get_node("StaticPlayer").target_puppet_path).call("_call_function", "UI/Inventory/Inventory", "add_item", [int(args[0])])

## GDSh command
## Spawns NPC near you (make sure you run away, if it is hostile)
func spawn_npc(args: Array):
	if args.size() > 0:
		if args[0].is_valid_int():
			if int(args[0]) < get_parent().gamedata.puppet_classes.size() && int(args[0]) > 0:
				var npc: MovableNpc = load("res://PlayerScript/NPCBase.tscn").instantiate()
				npc.puppet_class = get_parent().gamedata.puppet_classes[int(args[0])]
				npc.position = get_parent().protagonist.global_position - get_parent().protagonist.global_transform.basis.z * 4
				get_parent().get_node("NPCs").add_child(npc)
			elif int(args[0]) == -1:
				if get_parent().map_seed_name.to_lower() == "hikkan":
					# Hikkan / Hikkiko
					# What I have written? - Yni
					var npc: MovableNpc = load("res://PlayerScript/NPCBase.tscn").instantiate()
					npc.puppet_class = load("res://PlayerScript/PlayerClassResources/EasterEgg/Hikkan.tres")
					npc.position = get_parent().protagonist.global_position - get_parent().protagonist.global_transform.basis.z * 4
					get_parent().get_node("NPCs").add_child(npc)

## GDSh command
## Adds available task
func add_task(args: Array):
	if args.size() > 0:
		get_parent().get_node("FoundationTask").add_task(args[0])
