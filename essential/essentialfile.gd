extends Node3D

func _ready():
	var file_path = "res://essential/teto_egg.png"

	if not FileAccess.file_exists(file_path):
		print("File does not exist")
		get_tree().quit()
	else:
		print("File exists")
		
