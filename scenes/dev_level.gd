extends Node2D

@export var player: CharacterBody2D
@export var HUD: CanvasLayer
@export var camera: Camera2D

var deaths = 0

func add_death():
	deaths += 1
	return deaths

var enableSmoothingNextFrame = false

var cameraFollowObject: Node2D
var cameraFollowSpeed: float = 5.0
var cameraIsFollowing = true

var startedDebugRace = false
var currentDebugRaceTimer: float = 0.0
var bestRaceTime: float = 9999.0

func grav_pusher_entered(body):
	if body == player:
		player.externalForce = Vector2(0, -50)
		print(player.externalForce)

func grav_pusher_exited(body):
	if body == player:
		player.externalForce = Vector2.ZERO
		print(player.externalForce)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var gravPushers = get_tree().get_nodes_in_group("GravPushers")
	for gravPusher in gravPushers:
		print("connected gravPusher")
		gravPusher.connect("body_entered", grav_pusher_entered)
		gravPusher.connect("body_exited", grav_pusher_exited)


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
	else:
		cameraFollowObject = player
	
func _physics_process(delta: float) -> void:
	if startedDebugRace:
		currentDebugRaceTimer += delta
		HUD.set_timer(currentDebugRaceTimer)


func _on_debug_start_body_entered(body: Node2D) -> void:
	if body == player and startedDebugRace == false:
		print("starting race")
		currentDebugRaceTimer = 0.0
		startedDebugRace = true


func _on_debug_finish_body_entered(body: Node2D) -> void:
	if body == player and startedDebugRace == true:
		print("finishing race")
		if currentDebugRaceTimer < bestRaceTime:
			HUD.set_best_time(currentDebugRaceTimer)
			bestRaceTime = currentDebugRaceTimer
		startedDebugRace = false


func _on_level_body_entered(body: Node2D) -> void:
	if body == player:
		print("[debugLevel] player entered level")
		cameraIsFollowing = false
		player.ChangeState(player.States.Locked)


func _on_level_body_exited(body: Node2D) -> void:
	if body == player:
		print("[debugLevel] player exited level")
		cameraIsFollowing = true 
		player.ChangeState(player.States.Locked)


func _on_killzone_body_entered(body: Node2D) -> void:
	body.position = Vector2(0,100)
	var deaths = add_death()
	HUD.set_deaths(deaths)
