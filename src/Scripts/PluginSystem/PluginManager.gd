extends Node
## Loads plugins from user folder.
## Made by Yni, licensed under MIT license.

const VALIDATION_PUPPET_PLUGIN: Dictionary = {
	"gltf": {
		"gltf_file_prefix": "String",
		"gltf_file_suffix": "String",
		"gltf_path_to_find": "String"
	},
	"puppet_resource": {
		"speed": "float",
		"spawn_point_group": "String",
		"initial_amount": "float",
		"interacting_action": "float",
		"fraction": "float",
		"team": "float",
		"wandering_system": "float",
		"special_wandering_group": "String",
		"health": "Array",
		"enable_avoidance": "bool",
		"spawn_on_start": "bool",
		"puppet_navigation_layers": "float",
		"enable_ik": "bool",
		"disable_move_on_slide": "bool",
		"can_ride": "bool",
		"start_items": "Array",
		"start_money": "Dictionary",
		"enable_advanced_ai": "bool",
		"immortal": "bool",
		"keycards": "Array"
	}
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

## Loads puppet plugins
func _load_plugins():
	if !DirAccess.dir_exists_absolute("user://mods/puppets/custom"):
		DirAccess.make_dir_recursive_absolute("user://mods/puppets/custom")
	# Looking for plugins
	var dir: DirAccess = DirAccess.open("user://mods/puppets/custom")
	
	for sub_dir_name in dir.get_directories():
		var sub_dir: DirAccess = DirAccess.open("user://mods/puppets/custom".path_join(sub_dir_name))
		if sub_dir.get_files().has("plugin.json"):
			# Found plugin!
			var file: FileAccess = FileAccess.open("user://mods/puppets/custom".path_join(sub_dir_name).path_join("plugin.json"), FileAccess.READ)
			var file_content: String = file.get_as_text()
			# If is valid JSON
			if file_content.contains("{") && file_content.contains("}"):
				var plugin_dict: Dictionary = JSON.parse_string(file_content)
				#If plugin is valid plugin
				if is_plugin_valid(plugin_dict):
					#Currently, the only option
					if plugin_dict["plugin_type"] == "puppet":
						# Creating custom puppet prefab
						var custom_puppet: CustomPuppetScript = CustomPuppetScript.new()
						custom_puppet.enable_gltf_loading = true
						custom_puppet.custom = true
						# Seeding with settings
						for gltf_key in plugin_dict["gltf"]:
							custom_puppet.set(gltf_key, plugin_dict["gltf"][gltf_key])
						# Packing it for custom class
						var packed_scene:PackedScene = PackedScene.new()
						packed_scene.pack(custom_puppet)
						
						custom_puppet.queue_free()
						
						# Creating custom class
						var custom_puppet_res: PuppetClass = PuppetClass.new()
						# Seeding with settings
						for puppet_key in plugin_dict["puppet_resource"]:
							custom_puppet_res.set(puppet_key, plugin_dict["puppet_resource"][puppet_key])
						custom_puppet_res.puppet_class_name = "CUSTOM"
						# Assigning custom prefab
						custom_puppet_res.prefab = packed_scene
						# New custom class
						get_parent().gamedata.puppet_classes.append(custom_puppet_res)

## Plugin validator
func is_plugin_valid(plugin_dict: Dictionary) -> bool:
	if plugin_dict.has("plugin_type") && plugin_dict.has("license") && \
	   plugin_dict.has("author") && plugin_dict.has("name"):
		if plugin_dict["plugin_type"] is String && \
		   plugin_dict["license"] is String && \
		   plugin_dict["author"] is String && \
		   plugin_dict["name"] is String:
			match plugin_dict["plugin_type"]:
				"puppet":
					if plugin_dict.has("gltf") && plugin_dict.has("puppet_resource"):
						for gltf_key in VALIDATION_PUPPET_PLUGIN["gltf"]:
							if !plugin_dict["gltf"].has(gltf_key):
								return false
							
							if type_string(typeof(plugin_dict["gltf"][gltf_key])) != VALIDATION_PUPPET_PLUGIN["gltf"][gltf_key]:
								return false
						for puppet_key in VALIDATION_PUPPET_PLUGIN["puppet_resource"]:
							if !plugin_dict["puppet_resource"].has(puppet_key):
								return false
							
							if type_string(typeof(plugin_dict["puppet_resource"][puppet_key])) != VALIDATION_PUPPET_PLUGIN["puppet_resource"][puppet_key]:
								return false
						return true
	return false
