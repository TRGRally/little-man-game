extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	
	
func _input(event) -> void:
	if event.is_action_pressed("menu"):
		print("menu pressed")
		get_tree().change_scene_to_file("res://scenes/title_screen.tscn")



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
