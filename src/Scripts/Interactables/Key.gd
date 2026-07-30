extends InteractableRigid
class_name InteractableKey

@export var keycard_access: int = 0

func interact(player: Node3D):
	if player is MovableNpc:
		super.interact(player)
		player.keycards.append(keycard_access)
		queue_free()
