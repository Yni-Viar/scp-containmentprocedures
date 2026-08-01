extends InteractableStatic



func _on_visible_on_screen_notifier_3d_screen_entered() -> void:
	# Achievement
	if Settings.setting_res.scp_study_progress_all.has("SCP-079"):
		if !Settings.setting_res.scp_study_progress_all["SCP-079"]:
			Settings.setting_res.scp_study_progress_all["SCP-079"] = true
			Settings.save_resource(Settings.setting_res)
