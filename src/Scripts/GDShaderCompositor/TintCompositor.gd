extends MeshInstance3D
## Tint compositor (Alpha-channel based)
## Made by Yni, licensed under MIT License.

## All available shaders
@export var shaders: Dictionary[String, ShaderMaterial]
## Leave this empty
@export var used_shaders: Array[String] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

## Adds (or removes if remove is set to true) a tint by it's key in `shaders` variable
func apply_shader(effect_name: String, remove: bool = false) -> bool:
	if OS.get_name() == "Web":
		return false
	if !shaders.keys().has(effect_name) || (used_shaders.has(effect_name) && !remove) || \
	 (!used_shaders.has(effect_name) && remove):
		return false
	if remove:
		used_shaders.erase(effect_name)
		if used_shaders.size() == 0:
			hide()
			set_surface_override_material(0, null)
			return true
	else:
		used_shaders.append(effect_name)
		show()
	var material: ShaderMaterial
	var tmp_material: ShaderMaterial
	var tmp_material_initialized: bool = false
	for effect in used_shaders:
		if material == null:
			material = shaders[effect].duplicate()
		elif material != null:
			if tmp_material == null:
				if !tmp_material_initialized:
					material.next_pass = shaders[effect].duplicate()
					tmp_material = material.next_pass
					tmp_material_initialized = true
				else:
					tmp_material = shaders[effect].duplicate()
			else:
				tmp_material.next_pass = shaders[effect].duplicate()
				tmp_material = tmp_material.next_pass
	set_surface_override_material(0, material)
	return true

## Applies strength to a shader with `effect_name` key to the tint with specific `intensity`
func apply_strength(effect_name: String, intensity: float):
	if used_shaders.is_empty():
		return false
	var material: ShaderMaterial = get_surface_override_material(0)
	if material == null:
		return false
	for used_effect in used_shaders:
		if used_effect == effect_name:
			material.set_shader_parameter("multiplier", intensity)
			return true
		material = material.next_pass
	return false
