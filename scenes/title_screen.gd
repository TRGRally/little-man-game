extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("title screen ready")
	%StartButton.grab_focus()
	print("FROM TITLE SCREEN")
	print(str(Global.saveData))
	print(str(Global.allLevels))
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_start_button_pressed() -> void:
	Global.saveData["currentLevel"] = "dev_level"
	Global.saveToFile()
	get_tree().change_scene_to_file("res://scenes/game.tscn")


func _on_test_button_pressed() -> void:
	Global.saveData["currentLevel"] = "room_test_level"
	Global.saveToFile()
	get_tree().change_scene_to_file("res://scenes/game.tscn")


func _on_exit_button_pressed() -> void:
	#notifies the scene tree of quit request, allows the game to prepare if necessary
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	#but for now just force quit
	get_tree().quit()


func _on_crazy_button_pressed() -> void:
	Global.saveData["currentLevel"] = "crazy_level"
	Global.saveToFile()
	get_tree().change_scene_to_file("res://scenes/game.tscn")
