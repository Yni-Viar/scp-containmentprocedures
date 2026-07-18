extends Node3D
class_name DoorBase
## Made by Yni, licensed under MIT License.

## The player can open the door.
@export var can_open: bool = true
## The door is actually opened.
@export var is_opened: bool = false
## Enables door sound
@export var enable_sound: bool = true
## Door open sound variations
@export var open_door_sounds: Array[String]
## Door close sound variations
@export var close_door_sounds: Array[String]
## Is this door keycarded? 
## Useless for elevator doors!
@export var check_keycards: bool = false
## Which keycard can open this door
@export var required_keycards: Array[int] = []

# Called when the node enters the scene tree for the first time.
func _ready():
	if is_opened:
		door_open()


## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#pass

## Main control method, which checks - is the door opened.
func door_control(player_path: String):
	if can_open:
		if (check_keycards && check_keycard(player_path)) != !check_keycards:
			door_controller()
	#else:
		#$DoorSound.stream = load()

## If DoorControl check is successful, open the door (or close)
func door_controller():
	if is_opened && !get_node("AnimationPlayer").is_playing():
		door_close()
	elif !get_node("AnimationPlayer").is_playing():
		door_open()

## Open the door
func door_open():
	var rng = RandomNumberGenerator.new()
	if get_node_or_null("AnimationPlayer") != null:
		$AnimationPlayer.play("door_open")
	if !open_door_sounds.is_empty() && get_node_or_null("DoorSound") != null:
		$DoorSound.stream = load(open_door_sounds[rng.randi_range(0, open_door_sounds.size() - 1)])
		$DoorSound.play()
	is_opened = true
## Closes the door
func door_close():
	var rng = RandomNumberGenerator.new()
	if get_node_or_null("AnimationPlayer") != null:
		$AnimationPlayer.play("door_open", -1, -1, true)
	if !open_door_sounds.is_empty() && get_node_or_null("DoorSound") != null:
		$DoorSound.stream = load(close_door_sounds[rng.randi_range(0, close_door_sounds.size() - 1)])
		$DoorSound.play()
	is_opened = false

## Checks keycards
func check_keycard(player_path: String) -> bool:
	var player = get_node(player_path)
	if player is MovableNpc:
		# 0 is SCP-005 and 16 is Casual mode keycard
		if player.keycards.has(0) || player.keycards.has(16):
			return true
		for key in player.keycards:
			if required_keycards.has(key):
				return true
		return false
	else:
		return false
