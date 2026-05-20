extends PathFollow3D
class_name PathWalker
## Made by Yni, licensed under MIT License.
## Vacuum cleaner function.

@export var enable_interact: bool = true
@export var speed: float = 0.005
var enabled: bool = true
var transition: bool = false
var counter: int = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func interact():
	if enable_interact:
		transition = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if enabled:
		progress_ratio += speed * delta
	if transition:
		if enabled:
			# stop moving
			progress_ratio += move_toward(0.005, 0, delta) * delta
			$Sound.volume_db = move_toward(0, -10, delta) * delta
			counter += 1
		else:
			# start moving
			progress_ratio += move_toward(0, 0.005, delta) * delta
			$Sound.volume_db = move_toward(-10, 0, delta) * delta
			counter += 1
		if counter == 5:
			# change values on stopping/starting
			enabled = !enabled
			$Sound.playing = !$Sound.playing
			counter = 0
			transition = false


func _on_visibility_changed() -> void:
	enabled = visible
