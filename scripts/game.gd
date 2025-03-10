extends Node2D

@onready var HUD = %HUD
@onready var camera = %PlayerCamera
@onready var player = $Player
	

var levelInstance = null
var currentLevel = null


func changeLevel(sceneName: String):
	var scene = load(Global.allLevels[sceneName])
	levelInstance = scene.instantiate()
	currentLevel = sceneName
	add_child(levelInstance)
	levelInstance.player = player
	levelInstance.HUD = HUD
	levelInstance.camera = camera
	Global.saveData["currentLevel"] = sceneName
	Global.saveToFile()
	print("Loaded scene: " + scene.resource_name)
	
	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Engine.set_time_scale(1)
	if Global.saveData["currentLevel"]:
		changeLevel(Global.saveData["currentLevel"])
	else:
		#load title_screen for first time start
		var scene = load("res://scenes/title_screen.tscn").instantiate()
		get_tree().root.add_child(scene)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _physics_process(delta: float) -> void:
	pass

	
