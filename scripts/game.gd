extends Node2D

@onready var gameManager = %GameManager
@onready var HUD = %HUD
@onready var camera = %PlayerCamera
@onready var player = $Player

var enableSmoothingNextFrame = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Engine.set_time_scale(1.0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if enableSmoothingNextFrame:
		enableSmoothingNextFrame = false
		camera.position_smoothing_enabled = true
			
	#camera toggle	
	if Input.is_action_just_pressed("ui_cancel"): #escape
		
			
		var mode = gameManager.toggle_cam()
		set_cam_mode(mode)
		

func set_cam_mode(isFollowing):
	if isFollowing:
		camera.position_smoothing_enabled = false
		camera.reparent(player, false)
		camera.global_position = player.position
		enableSmoothingNextFrame = true
	else:
		camera.position_smoothing_enabled = false
		camera.reparent(self, false)
		camera.global_position = camera.DEV_ROOM_POSITION
		enableSmoothingNextFrame = true


func _on_area_2d_body_entered(body: Node2D) -> void:
	body.position = Vector2(0,100)
	var deaths = gameManager.add_death()
	HUD.set_deaths(deaths)
	
