extends Node2D

@export var player: CharacterBody2D
@export var HUD: CanvasLayer
@export var camera: Camera2D

var SPAWN_POSITION: Vector2 = Vector2(-1100, 520)

var deaths = 0

func add_death():
	deaths += 1
	return deaths


var cameraFollowObject: Node2D
var cameraFollowSpeed: float = 6.0
var cameraIsFollowing = true
var cameraAnchor: Vector2 = Vector2(0,0)

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
		

func set_camera_anchor(anchor, transitionLockState):
	cameraAnchor = anchor
	cameraIsFollowing = false
	player.ChangeState(player.States.Locked)
	
func release_camera_anchor(transitionLockState):
	cameraIsFollowing = true
	player.ChangeState(player.States.Locked)
	
func camera_anchor_body_entered(body, binds):
	var area = binds[0]
	print("YOURMUM")
	print(area)
	if body == player:
		set_camera_anchor(area.anchor, area.transitionLockState)

func camera_anchor_body_exited(body, binds):
	var area = binds[0]
	if body == player:
		release_camera_anchor(area.transitionLockState)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var gravPushers = get_tree().get_nodes_in_group("GravPushers")
	var cameraLockAreas = get_tree().get_nodes_in_group("CameraLockAreas")
	for gravPusher in gravPushers:
		print("connected gravPusher")
		gravPusher.connect("body_entered", grav_pusher_entered)
		gravPusher.connect("body_exited", grav_pusher_exited)
		
	for area in cameraLockAreas:
		print("connected cameraLockArea")
		area.connect("body_entered", camera_anchor_body_entered.bind([area]))
		area.connect("body_exited", camera_anchor_body_exited.bind([area]))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if cameraFollowObject != null:
		if cameraIsFollowing == true:
			var pos_delta: Vector2 = camera.global_position - player.global_position
			var transform: Vector2 = pos_delta * cameraFollowSpeed * delta
			camera.global_position -= transform
		else:
			var pos_delta: Vector2 = camera.global_position - cameraAnchor
			var transform: Vector2 = pos_delta * cameraFollowSpeed * delta
			camera.global_position -= transform
	else:
		cameraFollowObject = player
		player.global_position = SPAWN_POSITION
		camera.global_position = player.global_position
	
func _physics_process(delta: float) -> void:
	if startedDebugRace:
		currentDebugRaceTimer += delta
		HUD.set_timer(currentDebugRaceTimer)


func _on_debug_start_body_entered(body: Node2D) -> void:
	if body == player and startedDebugRace == true:
		print("abandoning race")
		startedDebugRace = false
		HUD.set_timer(0.0)


func _on_debug_finish_body_entered(body: Node2D) -> void:
	if body == player and startedDebugRace == true:
		print("finishing race")
		if currentDebugRaceTimer < bestRaceTime:
			HUD.set_best_time(currentDebugRaceTimer)
			bestRaceTime = currentDebugRaceTimer
		startedDebugRace = false


func _on_killzone_body_entered(body: Node2D) -> void:
	body.position = Vector2(0,100)
	var deaths = add_death()
	HUD.set_deaths(deaths)


func _on_debug_start_body_exited(body: Node2D) -> void:
	if body == player and startedDebugRace == false:
		print("starting race")
		currentDebugRaceTimer = 0.0
		startedDebugRace = true
