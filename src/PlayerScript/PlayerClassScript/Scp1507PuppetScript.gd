extends SkinnablePuppetScript
## SCP-1507 puppet script
## Created by Yni, licensed under dual license: for SCP content - GPL 3, for non-SCP - MIT License

## DORMANT state used by default while following PoI-1507, unless player tapped.
## PURSUING state, when SCP-1507 pursues player.
## ATTACKING state, when player is being pursued AND is close to SCP-1507
enum Scp1507State {DORMANT, PURSUING, ATTACKING}

## Current state (see Scp1507State documentation)
@export var scp_1507_state: Scp1507State = Scp1507State.DORMANT
## Customizable attack cooldown.
@export var attack_cooldown: float = 2.0

var timer = 0.0

# Called when the node enters the scene tree for the first time.
func on_spawned() -> void:
	get_parent().get_parent().follow_target = get_tree().get_first_node_in_group("PoI1507").get_path()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	match state:
		States.IDLE:
			set_state("idle")
		States.WALKING, States.RUNNING:
			set_state("move")
	if scp_1507_state == Scp1507State.ATTACKING:
		timer += delta
		if timer > attack_cooldown:
			attack(get_parent().get_parent().follow_target)
			timer = 0.0
	elif scp_1507_state == Scp1507State.DORMANT && get_node(get_parent().get_parent().follow_target) == null:
		# If PoI-1507 is killed, beceom hostile to the player
		special_action()

## Play specific animation
func set_state(anim: String):
	if puppet_node.get_node("AnimationPlayer").current_animation != anim:
		puppet_node.get_node("AnimationPlayer").play(anim)

## If tapped on SCP-1507, they will attack
func special_action():
	scp_1507_state = Scp1507State.PURSUING
	get_parent().get_parent().follow_target = get_tree().root.get_node("Game").protagonist.get_path()

## Attack player
func attack(collider_path: String):
	var test = get_node(collider_path)
	if test != null:
		test.health_manage(-5.0)

func _on_attack_body_entered(body: Node3D) -> void:
	if body is MovableNpc:
		if scp_1507_state == Scp1507State.PURSUING && body.is_player:
			scp_1507_state = Scp1507State.ATTACKING


func _on_attack_body_exited(body: Node3D) -> void:
	if body is MovableNpc:
		if scp_1507_state == Scp1507State.ATTACKING && body.is_player:
			scp_1507_state = Scp1507State.PURSUING


func _on_achievement_screen_entered() -> void:
	#Achievement
	if Settings.setting_res.scp_study_progress_all.has("SCP-1507"):
		if !Settings.setting_res.scp_study_progress_all["SCP-1507"]:
			Settings.setting_res.scp_study_progress_all["SCP-1507"] = true
			Settings.save_resource(Settings.setting_res)
