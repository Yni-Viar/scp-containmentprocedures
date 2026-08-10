extends Panel
## Credits container, which shows in the game ending
## Made by Yni, licensed under MIT license.
## some content may be made by Godot contributors and is
## licensed under MIT License

@export var activated: bool = false
@export var result_text: String = ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if activated:
		#Used Godot engine approach
		if Input.is_action_pressed("click"):
			$VBoxContainer.position = Vector2($VBoxContainer.position.x, $VBoxContainer.position.y - 2000 * delta)
		else:
			$VBoxContainer.position = Vector2($VBoxContainer.position.x, $VBoxContainer.position.y - 100 * delta)
		if $VBoxContainer.position.y < -$VBoxContainer.get_size().y + 640:
			activated = false


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
					$VBoxContainer.add_child(label)
				_:
					var label: Label = Label.new()
					label.text = project_title + "\n" + credit_section[project_title]
					label.add_theme_font_override("theme_override_fonts/font", load("res://Assets/Fonts/Farabee/Farabee_Regular.ttf"))
					label.add_theme_font_size_override("theme_override_font_sizes/font_size", 20)
					$VBoxContainer.add_child(label)
	var label: Label = Label.new()
	label.text = "THANKS_FOR_PLAYING"
	label.add_theme_font_override("theme_override_fonts/font", load("res://Assets/Fonts/Farabee/Farabee_Regular.ttf"))
	label.add_theme_font_size_override("theme_override_font_sizes/font_size", 20)
	$VBoxContainer.add_child(label)
	var postscriptum: Label = Label.new()
	postscriptum.text = text
	$VBoxContainer.add_child(postscriptum)
	var exit_button: Button = Button.new()
	exit_button.text = "BACK_TO_MENU"
	exit_button.connect("pressed", _on_back_pressed)
	$VBoxContainer.add_child(exit_button)
	activated = true

func _on_back_pressed() -> void:
	Settings.loader("res://Scenes/Menu.tscn", {})
