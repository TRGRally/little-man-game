extends Node2D

@onready var gameManager = %GameManager
@onready var HUD = %HUD
@onready var camera = %PlayerCamera
@onready var player = $Player

var enableSmoothingNextFrame = false

var cameraFollowObject: Node2D
var cameraFollowSpeed: float = 5.0
var cameraIsFollowing = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Engine.set_time_scale(1)
	cameraFollowObject = player


 

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if cameraFollowObject != null:
		
		if cameraIsFollowing == true:
			var direction: Vector2 = camera.global_position - player.global_position
			var transform: Vector2 = direction * cameraFollowSpeed * delta
			camera.global_position -= transform
		else:
			var direction: Vector2 = camera.global_position - camera.DEV_ROOM_POSITION
			var transform: Vector2 = direction * cameraFollowSpeed * delta
			camera.global_position -= transform



func _on_area_2d_body_entered(body: Node2D) -> void:
	body.position = Vector2(0,100)
	var deaths = gameManager.add_death()
	HUD.set_deaths(deaths)



func _on_grav_pusher_body_entered(body: Node2D) -> void:
	if body == player:
		player.externalForce = Vector2(0, -50)
		print(player.externalForce)
		
		
func _on_grav_pusher_2_body_entered(body: Node2D) -> void:
	if body == player:
		player.externalForce = Vector2(0, -50)
		print(player.externalForce)
		
func _on_grav_pusher_2_body_exited(body: Node2D) -> void:
	player.externalForce = Vector2.ZERO
	print(player.externalForce)



func _on_grav_pusher_body_exited(body: Node2D) -> void:
	player.externalForce = Vector2.ZERO
	print(player.externalForce)


func _on_level_body_entered(body: Node2D) -> void:
	if body == player:
		cameraIsFollowing = false
		player.ChangeState(player.States.Locked)


func _on_level_body_exited(body: Node2D) -> void:
	if body == player:
		cameraIsFollowing = true 
		player.ChangeState(player.States.Locked)


func _on_grav_pusher_3_body_entered(body: Node2D) -> void:
	if body == player:
		player.externalForce = Vector2(0, -50)
		print(player.externalForce)


func _on_grav_pusher_3_body_exited(body: Node2D) -> void:
	player.externalForce = Vector2.ZERO
	print(player.externalForce)
