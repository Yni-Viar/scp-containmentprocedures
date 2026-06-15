extends Node
## Game task manager
## Created by Yni, licensed under dual license: for SCP content - GPL 3, for non-SCP - MIT License

enum SpecialEvent {NONE, POSITIVE, NEGATIVE}

signal task_done

var tasks_left: int = 2
var all_tasks: Array[GameTaskResource]
var all_tasks_bkp: Array[GameTaskResource]

var aliases: Dictionary[String, String] = {}

var special_event: SpecialEvent = SpecialEvent.NONE


# Called when the node enters the scene tree for the first time.
func initialize() -> void:
	all_tasks.clear()
	var used_index: PackedInt32Array = []
	for i in range(tasks_left):
		# If there is too few tasks - stop loop.
		if get_parent().gamedata.tasks.size() - 1 < i:
			break
		var task_index: int
		while true:
			task_index = get_parent().rng.randi_range(0, get_parent().gamedata.tasks.size() - 1)
			
			# If the task already defined - stop infinite loop.
			if !used_index.has(task_index):
				# If spawn do not exist - append task as used.
				for group in get_parent().gamedata.tasks[task_index].required_groups:
					if get_tree().get_node_count_in_group(group) == 0:
						used_index.append(task_index)
						break
				# If spawn exist - break infinite loop
				if !used_index.has(task_index):
					break
			# If all tasks are used - finish initialize.
			if get_parent().gamedata.tasks.size() == used_index.size():
				return
		if !used_index.has(task_index):
			used_index.append(task_index)
			# Sub tasks logic
			if get_parent().gamedata.tasks[task_index].sub_tasks != null && !get_parent().gamedata.tasks[task_index].sub_tasks.is_empty():
				var sub_task_index: int = get_parent().rng.randi_range(0, get_parent().gamedata.tasks[task_index].sub_tasks.size() - 1)
				aliases[get_parent().gamedata.tasks[task_index].sub_tasks[sub_task_index].internal_name] = get_parent().gamedata.tasks[task_index].internal_name
				all_tasks.append(get_parent().gamedata.tasks[task_index].sub_tasks[sub_task_index])
			else:
				# Regular task
				all_tasks.append(get_parent().gamedata.tasks[task_index])

## Adds task manually, if it is possible to complete.
func add_task(task_name: String):
	for task in get_parent().gamedata.tasks:
		if task.internal_name == task_name:
			for group in task.required_groups:
				if get_tree().get_node_count_in_group(group) == 0:
					return
			all_tasks.append(task)
			task_done.emit()
			break

## Do task with specified internal name
func do_task(task_name: String):
	for task in all_tasks:
		if task.internal_name == task_name:
			if special_event == SpecialEvent.NONE:
				#if aliases.has(task.internal_name):
					#Settings.setting_res.casual_game_progress.append(aliases[task.internal_name])
				#else:
					#Settings.setting_res.casual_game_progress.append(task.internal_name)
				#Achievement
				match task.internal_name:
					"task_5270_2306":
						if Settings.setting_res.scp_study_progress_all.has("SCP-2306") && Settings.setting_res.scp_study_progress_all.has("SCP-5270"):
							if !Settings.setting_res.scp_study_progress_all["SCP-2306"] && !Settings.setting_res.scp_study_progress_all["SCP-5270"]:
								Settings.setting_res.scp_study_progress_all["SCP-2306"] = true
								Settings.setting_res.scp_study_progress_all["SCP-5270"] = true
								Settings.save_resource(Settings.setting_res)
					"task_914_exp_5":
						if Settings.setting_res.scp_study_progress_all.has("SCP-005"):
							if !Settings.setting_res.scp_study_progress_all["SCP-005"]:
								Settings.setting_res.scp_study_progress_all["SCP-005"] = true
								Settings.save_resource(Settings.setting_res)
				Settings.save_resource(Settings.setting_res)
			all_tasks.erase(task)
			task_done.emit()
			break

## Trigger event - replace all tasks for a while with specific task.
func trigger_event(event_type: SpecialEvent, res: GameTaskResource = null):
	special_event = event_type
	if special_event == SpecialEvent.NONE || res == null:
		all_tasks.clear()
		all_tasks = all_tasks_bkp.duplicate(true)
		all_tasks_bkp.clear()
	else:
		all_tasks_bkp = all_tasks.duplicate(true)
		all_tasks.clear()
		all_tasks.append(res)
	if get_parent().get_node_or_null("SoundStreamPlayer") != null:
		var audio: AudioStreamPlayer = get_parent().get_node("SoundStreamPlayer")
		audio.stream = load("res://Sounds/Generic/TaskComplete.ogg")
		audio.play()
	task_done.emit()

## Returns true if task exist (requires task's internal name)
func has_task(task_name: String) -> bool:
	for task in all_tasks:
		if task.internal_name == task_name:
			return true
	return false
