extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("title screen ready")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")


func _on_test_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")
