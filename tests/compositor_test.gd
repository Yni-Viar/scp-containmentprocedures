extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_pressed() -> void:
	$StaticPlayer/Head/Camera3D/Overlays/OverlayCompositor.apply_shader(randi_range(0, $StaticPlayer/Head/Camera3D/Overlays/OverlayCompositor.shaders.size() - 1))


func _on_button_2_pressed() -> void:
	$StaticPlayer/Head/Camera3D/Overlays/OverlayCompositor.apply_shader(randi_range(0, $StaticPlayer/Head/Camera3D/Overlays/OverlayCompositor.shaders.size() - 1), true)


func _on_button_3_pressed() -> void:
	$StaticPlayer/Head/Camera3D/Overlays/TintCompositor2.apply_shader($StaticPlayer/Head/Camera3D/Overlays/TintCompositor2.shaders.keys()[randi_range(0, $StaticPlayer/Head/Camera3D/Overlays/TintCompositor2.shaders.size() - 1)])


func _on_button_4_pressed() -> void:
	$StaticPlayer/Head/Camera3D/Overlays/TintCompositor2.apply_shader($StaticPlayer/Head/Camera3D/Overlays/TintCompositor2.shaders.keys()[randi_range(0, $StaticPlayer/Head/Camera3D/Overlays/TintCompositor2.shaders.size() - 1)], true)


func _on_button_5_pressed() -> void:
	$StaticPlayer/Head/Camera3D/Overlays/TintCompositor2.apply_strength("Cold", randf())
