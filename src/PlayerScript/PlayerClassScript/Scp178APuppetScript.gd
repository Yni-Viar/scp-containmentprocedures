extends BasePuppetScript

## SCP-178-1 puppet script
## Created by Yni, licensed under dual license: for SCP content - GPL 3, for non-SCP - MIT License

static var target_players: Array[MovableNpc]

var targeted: bool = false:
	set(val):
		if val:
			get_parent().get_parent().character_speed = get_parent().get_parent().puppet_class.speed * 8
		else:
			get_parent().get_parent().character_speed = get_parent().get_parent().puppet_class.speed
		targeted = val

## Attack timer
var attack_update_timer: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	match state:
		States.IDLE:
			set_state("Idle")
		States.WALKING, States.RUNNING:
			set_state("Walk")
	
	if target_players.size() > 0:
		if target_players[0] == null:
			target_players.remove_at(0)
			if target_players.size() == 0 && targeted:
				targeted = false
		else:
			if !targeted:
				targeted = true
			get_parent().get_parent().follow_target = target_players[0].get_path()
	else:
		get_parent().get_parent().follow_target = ""

func set_state(anim: String):
	if get_node_or_null("AnimationPlayer") != null:
		if $AnimationPlayer.current_animation != anim:
			$AnimationPlayer.play(anim)

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is MovableNpc:
		if body.is_player:
			if !target_players.has(body):
				target_players.append(body)
			else:
				attack()

func attack():
	if attack_update_timer > 0:
		attack_update_timer -= get_physics_process_delta_time()
	else:
		var test = get_parent().get_parent().follow_target
		get_node(test).health_manage(-50.0, 0, "GAME_OVER_SCP_178")
		attack_update_timer = 0.375
		set_state("Attack")
