extends Panel
## Credits container, which showed in the game ending
## Made by Yni, licensed under MIT license.

@export var result_text: String = ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$CreditsContainer.scroll_vertical += 1.0


func launch_credits(text: String, image: Texture2D) -> void:
	$TextureRect.texture = image
	var credit_manager: CreditsManager = CreditsManager.new()
	var result_credits: Array[Dictionary] = credit_manager.get_full_list()
	for credit_section in result_credits:
		for project_title in credit_section:
			match project_title:
				"|Epilogue|", "ThirdParty":
					var label: Label = Label.new()
					label.text = credit_section[project_title]
					label.add_theme_font_override("theme_override_fonts/font", load("res://Assets/Fonts/Farabee/Farabee_Regular.ttf"))
					label.add_theme_font_size_override("theme_override_font_sizes/font_size", 28)
					$CreditsContainer/VBoxContainer.add_child(label)
				_:
					var label: Label = Label.new()
					label.text = project_title + "\n" + credit_section[project_title]
					label.add_theme_font_override("theme_override_fonts/font", load("res://Assets/Fonts/Farabee/Farabee_Regular.ttf"))
					label.add_theme_font_size_override("theme_override_font_sizes/font_size", 20)
					$CreditsContainer/VBoxContainer.add_child(label)
	var label: Label = Label.new()
	label.text = "THANKS_FOR_PLAYING"
	label.add_theme_font_override("theme_override_fonts/font", load("res://Assets/Fonts/Farabee/Farabee_Regular.ttf"))
	label.add_theme_font_size_override("theme_override_font_sizes/font_size", 20)
	$CreditsContainer/VBoxContainer.add_child(label)
	var postscriptum: Label = Label.new()
	postscriptum.text = text
	$CreditsContainer/VBoxContainer.add_child(postscriptum)
	var exit_button: Button = Button.new()
	exit_button.text = "BACK_TO_MENU"
	exit_button.connect("pressed", _on_back_pressed)
	$CreditsContainer/VBoxContainer.add_child(exit_button)
	for i in range(3):
		var filler_label: Label = Label.new()
		$CreditsContainer/VBoxContainer.add_child(filler_label)

func _on_back_pressed() -> void:
	Settings.loader("res://Scenes/Menu.tscn", {})
