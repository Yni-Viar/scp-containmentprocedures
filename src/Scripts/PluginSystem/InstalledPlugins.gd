extends ItemList
## Made by Yni, licensed under MIT license.
## Uses Godot Engine code, which is under MIT License


@export var plugins_paths: Array[String]
var file_dialog: FileDialog
var selected_index: int = -1


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	refresh_list()


func refresh_list() -> void:
	clear()
	if OS.get_name() == "Web" && !Settings.ALLOW_PLUGINS_IN_WEB:
		return
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
				var plugin_name: String = plugin_dict["name"] if plugin_dict.has("name") else "unknown"
				var plugin_author: String = plugin_dict["author"] if plugin_dict.has("author") else "unknown"
				var plugin_type: String = plugin_dict["plugin_type"] if plugin_dict.has("plugin_type") else "unknown"
				var plugin_api: String = str(int(plugin_dict["api_version"][0])) + "." + str(int(plugin_dict["api_version"][1])) + "." + str(int(plugin_dict["api_version"][2])) if plugin_dict.has("api_version") else "10.0.0 or unknown"
				plugins_paths.append("user://mods/puppets/custom".path_join(sub_dir_name))
				add_item(tr("PLUGIN_NAME") + ": " + plugin_name + "\n" + tr("PLUGIN_AUTHOR") + ": " + plugin_author + "\n" + tr("PLUGIN_TYPE") + ": " + tr(plugin_type) + "\n" + tr("API_VERSION") + ": " + plugin_api, load("res://UI/plugin_icon.png"))

func _on_plugin_install_button_pressed() -> void:
	if file_dialog == null:
		file_dialog = FileDialog.new()
		file_dialog.theme = load("res://UITheme_FileDialog.tres")
		file_dialog.access = FileDialog.ACCESS_FILESYSTEM
		file_dialog.initial_position = Window.WINDOW_INITIAL_POSITION_CENTER_MAIN_WINDOW_SCREEN
		file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
		file_dialog.filters = ["*.zip", "application/zip"]
		file_dialog.visible = true
		if OS.get_name() == "Android":
			file_dialog.use_native_dialog = true
		file_dialog.canceled.connect(_on_file_dialogue_canceled)
		file_dialog.file_selected.connect(_on_file_dialogue_file_selected)
		get_tree().root.get_node("/root/Settings").add_child(file_dialog)

func _on_file_dialogue_canceled():
	if file_dialog != null:
		file_dialog.queue_free()
		file_dialog = null

func _on_file_dialogue_file_selected(path: String):
	extract_all_from_zip(path)
	refresh_list()

# BEGIN GODOT CODE

# Extract all files from a ZIP archive, preserving the directories within.
# This acts like the "Extract all" functionality from most archive managers.
func extract_all_from_zip(path: String):
	var reader = ZIPReader.new()
	reader.open(path)

	# Destination directory for the extracted files (this folder must exist before extraction).
	var root_dir = DirAccess.open("user://mods/puppets/custom")
	if root_dir == null:
		return

	var files = reader.get_files()
	
	# Check if files exist outside their folder
	for file_path in files:
		if !file_path.contains("/"):
			root_dir.make_dir(path.get_file().get_slice(".", 0))
			break
	
	for file_path in files:
		# If the current entry is a directory.
		if file_path.ends_with("/"):
			root_dir.make_dir_recursive(file_path)
			continue

		# Write file contents, creating folders automatically when needed.
		# Not all ZIP archives are strictly ordered, so we need to do this in case
		# the file entry comes before the folder entry.
		root_dir.make_dir_recursive(root_dir.get_current_dir().path_join(file_path).get_base_dir())
		var file = FileAccess.open(root_dir.get_current_dir().path_join(file_path), FileAccess.WRITE)
		var buffer = reader.read_file(file_path)
		file.store_buffer(buffer)


func _on_item_selected(index: int) -> void:
	selected_index = index


func _on_plugin_delete_button_pressed() -> void:
	if selected_index == -1:
		return
	elif DirAccess.dir_exists_absolute(plugins_paths[selected_index]) && OS.get_name() == "Android":
		DirAccess.remove_absolute(plugins_paths[selected_index])
		refresh_list()
