extends RefCounted
## Manager of the in-game credits
## Made by Yni, licensed under MIT License.
class_name CreditsManager

var credits_cache: Dictionary = {}

func _init() -> void:
	var internal_file: FileAccess = FileAccess.open("res://CreditList.json", FileAccess.READ)
	credits_cache = JSON.parse_string(internal_file.get_as_text())
	internal_file.close()

func get_full_list() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	result.resize(4)
	result[0] = {}
	# first party parse
	for project in credits_cache["FirstParty"]:
		result[0][project] = ""
		for authors in credits_cache["FirstParty"][project]:
			result[0][project] += "Copyright (c) "
			if authors.has("copyright year"):
				result[0][project] += authors["copyright year"] + " "
			result[0][project] += authors["author"]
			if authors.has("project"):
				result[0][project] += ",\nmade for " + authors["project"] + "\n"
			else:
				result[0][project] += "\n"
			result[0][project] += "Licensed under " + authors["license"] + "\n"
	
	# third-party parse
	result[1] = {}
	result[1]["ThirdParty"] = "Third-party content, used in this project:"
	result[2] = {}
	
	for project in credits_cache["ThirdParty"]:
		result[2][project] = ""
		for authors in credits_cache["ThirdParty"][project]:
			result[2][project] += "Copyright (c) "
			if authors.has("copyright year"):
				result[2][project] += authors["copyright year"] + " "
			result[2][project] += authors["author"]
			if authors.has("project"):
				result[2][project] += ",\nmade for " + authors["project"] + "\n"
			else:
				result[2][project] += "\n"
			result[2][project] += "Licensed under " + authors["license"] + "\n"
	result[3] = {}
	# Fonts
	result[3]["Font"] = ""
	for font in credits_cache["Fonts"]:
		result[3]["Font"] += font + "\n"
	
	# SCP-Wiki stuff
	result[3]["SCP"] = ""
	for font in credits_cache["SCP-Wiki content"]:
		result[3]["SCP"] += font + "\n"
	result[3]["|Epilogue|"] = credits_cache["Epilogue"]
	return result
