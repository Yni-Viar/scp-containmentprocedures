extends HumanPuppet


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if !OS.has_feature("Lite"):
		$HumanRig/Skeleton3D/cm_vitruvian_001.mesh.surface_set_material(1, load("res://Assets/ExternalModels/VitruvianHumanGenerator_CC0/textures/Optional/vitruvian_eye_full.tres"))
		$HumanRig/Skeleton3D/cm_vitruvian_001.mesh.surface_set_material(3, load("res://Assets/ExternalModels/VitruvianHumanGenerator_CC0/textures/Optional/sclera_full.tres"))


## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
