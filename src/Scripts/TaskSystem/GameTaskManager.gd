extends Node

enum SpecialEvent {NONE, POSITIVE, NEGATIVE}

signal task_done

var tasks_left: int = 2
var all_tasks: Array[GameTaskResource]
var all_tasks_bkp: Array[GameTaskResource]
var special_event: SpecialEvent = SpecialEvent.NONE

# Called when the node enters the scene tree for the first time.
func initialize() -> void:
	var used_index: Array[int] = []
	for i in range(tasks_left):
		if get_parent().gamedata.tasks.size() - 1 < i:
			break
		var task_index: int
		while true:
			task_index = get_parent().rng.randi_range(0, get_parent().gamedata.tasks.size() - 1)
			if get_tree().get_node_count_in_group(get_parent().gamedata.tasks[task_index].required_group) == 0 || get_parent().gamedata.tasks[task_index].required_group.is_empty():
				used_index.append(task_index)
			if !used_index.has(task_index):
				break
			if get_parent().gamedata.tasks.size() == used_index.size():
				return
		used_index.append(task_index)
		all_tasks.append(get_parent().gamedata.tasks[task_index])


func do_task(task_name: String):
	for task in all_tasks:
		if task.internal_name == task_name:
			all_tasks.erase(task)
			task_done.emit()
			break

func trigger_event(event_type: SpecialEvent, res: GameTaskResource = null):
	special_event = event_type
	if special_event == SpecialEvent.NONE || res == null:
		all_tasks = all_tasks_bkp.duplicate()
	else:
		all_tasks_bkp = all_tasks.duplicate()
		all_tasks.clear()
		all_tasks.append(res)
	task_done.emit()

func has_task(task_name: String) -> bool:
	for task in all_tasks:
		if task.internal_name == task_name:
			return true
	return false
