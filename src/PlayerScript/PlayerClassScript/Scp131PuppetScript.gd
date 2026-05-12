extends BasePuppetScript

@export_group("DO NOT TOUCH!")
@export var looking_at_target: bool = false

# Called when the node enters the scene tree for the first time.
func on_start():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	## Look at enemy
	if active_puppets.size() > 0 && state == States.IDLE:
		var prev_entity_distance: float = 16777216
		var index = 0
		# Fixing scientist not looking at 650 - now people will look at the nearest object
		for i in range(active_puppets.size()):
			var entity_distance: float = active_puppets[i].global_position.distance_to(get_parent().global_position)
			if entity_distance < prev_entity_distance || i == active_puppets.size() - 1:
				prev_entity_distance = entity_distance
				index = i
		
		var looking_object: Node3D
		
		# If there is must-not-look SCP (like 023), just watch SafePoint. Else, look directly, as 173 or 650
		if active_puppets[index].puppet_class.fraction == 3 && \
		active_puppets[index].get_node_or_null("PlayerModel/Puppet/SafeZone") != null:
			looking_object = active_puppets[index].get_node("PlayerModel/Puppet/SafeZone")
		else:
			looking_object = active_puppets[index]
		
		if active_puppets[index].puppet_class.fraction != 3:
			get_parent().get_parent().look_at(looking_object.global_position)
		looking_at_target = true
