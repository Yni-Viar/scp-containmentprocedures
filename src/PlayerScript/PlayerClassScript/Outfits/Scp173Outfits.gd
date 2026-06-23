extends Node3D
## Apply random SCP-173 outfit
## Applied only for built-in SCP-173!
## Made by Yni, licensed under MIT License.

@export var shader_material: ShaderMaterial
@export var regular_outfits: Array[Texture2D]
@export var christmas_outfits: Array[Texture2D]
@export var halloween_outfits: Array[Texture2D]
@export var mesh_to_override: MeshInstance3D
var current_id: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	match Settings.current_season:
		Settings.Season.CHRISTMAS:
			if !christmas_outfits.is_empty():
				current_id = randi_range(0, christmas_outfits.size() - 1)
				shader_material.set_shader_parameter("albedo_b", christmas_outfits[current_id])
				#shader_material.set_shader_parameter("albedo_b", load("res://Assets/ExternalModels/SCP/Optional/scp173/Faces/face_F1.png"))
		Settings.Season.HALLOWEEN:
			if !christmas_outfits.is_empty():
				current_id = randi_range(0, halloween_outfits.size() - 1)
				shader_material.set_shader_parameter("albedo_b", halloween_outfits[current_id])
				#shader_material.set_shader_parameter("albedo_b", load("res://Assets/ExternalModels/SCP/Optional/scp173/Faces/face_H1.png"))
		_:
			if !regular_outfits.is_empty():
				current_id = randi_range(0, regular_outfits.size() - 1)
				shader_material.set_shader_parameter("albedo_b", regular_outfits[current_id])
	mesh_to_override.set_surface_override_material(0, shader_material)
