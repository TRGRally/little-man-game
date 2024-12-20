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
	




func _on_grav_pusher_body_entered(body: Node2D) -> void:
	if body == player:
		player.externalForce = Vector2(0, -30)
		print(player.externalForce)



func _on_grav_pusher_body_exited(body: Node2D) -> void:
	player.externalForce = Vector2.ZERO
	print(player.externalForce)


func _on_level_body_entered(body: Node2D) -> void:
	if body == player:
		var mode = gameManager.room_cam()
		set_cam_mode(mode)


func _on_level_body_exited(body: Node2D) -> void:
	if body == player:
		var mode = gameManager.follow_cam()
		set_cam_mode(mode)
