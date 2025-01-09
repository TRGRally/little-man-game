extends Node2D

@onready var HUD = %HUD
@onready var camera = %PlayerCamera
@onready var player = $Player
	

var devLevel: PackedScene = load("res://scenes/dev_level.tscn")
var levelInstance = null


func changeLevel(scene: PackedScene):
	levelInstance = scene.instantiate()
	add_child(levelInstance)
	levelInstance.player = player
	levelInstance.HUD = HUD
	levelInstance.camera = camera
	print("Loaded scene: " + scene.resource_name)
	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Engine.set_time_scale(1)
	changeLevel(devLevel)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _physics_process(delta: float) -> void:
	pass

	
