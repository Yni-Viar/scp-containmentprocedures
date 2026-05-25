extends Resource
class_name GDShaderCompositorResource
## Shader snippet preset for GDShader Compositor
## Made by Yni, licensed under MIT License.

## Path to a shader to include
@export_file_path("*.gdshaderinc") var shader_path: String
## Shader callable
@export var shader_callable: String
## Shader global variables
@export var shader_variables: Dictionary[String, Variant]
## Is SCREEN_TEXTURE replaced
## REQUIRED for vec3 variables
@export var replace_screen_texture: bool = false
