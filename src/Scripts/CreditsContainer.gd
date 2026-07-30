extends Panel
## Credits container
## Made by Yni, licensed under MIT license.

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var credit_manager: CreditsManager = CreditsManager.new()
	var result_credits: Array[Dictionary] = credit_manager.get_full_list()
	for credit_section in result_credits:
		for project_title in credit_section:
			match project_title:
				"|Epilogue|", "ThirdParty":
					var label: Label = Label.new()
					label.text = credit_section[project_title]
					$CreditsContainer/VBoxContainer.add_child(label)
				_:
					var foldable_container: FoldableContainer = FoldableContainer.new()
					foldable_container.title = project_title
					foldable_container.folded = true
					var label: Label = Label.new()
					label.text = credit_section[project_title]
					foldable_container.add_child(label)
					$CreditsContainer/VBoxContainer.add_child(foldable_container)
