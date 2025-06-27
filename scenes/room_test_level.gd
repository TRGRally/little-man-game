extends Node2D

@export var player: CharacterBody2D
@export var HUD: CanvasLayer
@export var camera: Camera2D

var SPAWN_POSITION = Vector2(-288,76)

var cameraFollowObject: Node2D
var cameraFollowSpeed: float = 6.0
var cameraIsFollowing = true
var cameraAnchor: Vector2 = Vector2(0,0)

var roomsInside: Array[Node2D] = []

func set_camera_anchor(anchor):
	cameraAnchor = anchor
	cameraIsFollowing = false
	
func release_camera_anchor():
	cameraIsFollowing = true

func camera_anchor_body_entered(body, binds):
	var area = binds[0]
	if body == player:
		print("ENTER: " + area.name)
		roomsInside.append(area)
		#theres no difference between the two outcomes below but there might be in the future
		if player.currentRoom == null:
			#entering room from follow cam
			player.ChangeRoom(area)
			if player.currentRoom == area:
				set_camera_anchor(area.anchor)
		else:
			#entering room from another room 
			player.ChangeRoom(area)
			if player.currentRoom == area:
				set_camera_anchor(area.anchor)
		

func camera_anchor_body_exited(body, binds):
	var area = binds[0]
	if body == player:
		print("EXIT: " + area.name)
		roomsInside.erase(area)
		if roomsInside.size() == 0:
			player.ChangeRoom(null)
			if player.currentRoom == null:
				release_camera_anchor()
		else:
			var fallbackRoom = roomsInside.back()
			player.ChangeRoom(fallbackRoom)
			if player.currentRoom == fallbackRoom:
				set_camera_anchor(fallbackRoom.anchor)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var cameraLockAreas = get_tree().get_nodes_in_group("CameraLockAreas")
	for area in cameraLockAreas:
		print("connected cameraLockArea")
		area.connect("body_entered", camera_anchor_body_entered.bind([area]))
		area.connect("body_exited", camera_anchor_body_exited.bind([area]))


func _physics_process(delta: float) -> void:
	if player.currentRoom == null:
		cameraIsFollowing = true
	
	#if cameraFollowObject != null:
		#if cameraIsFollowing == true:
			#var pos_delta: Vector2 = camera.global_position - player.global_position
			#var transform: Vector2 = pos_delta * cameraFollowSpeed * delta
			#camera.global_position -= transform
		#else:
			##var pos_delta: Vector2 = camera.global_position - cameraAnchor
			##pos_delta.x = int(pos_delta.x)
			##pos_delta.y = int(pos_delta.y)
			##var transform: Vector2 = pos_delta * cameraFollowSpeed * delta
			##camera.global_position -= transform
			#print("lerp")
			#camera.global_position = lerp(camera.global_position, cameraAnchor, 0.125)
	#else:
		#cameraFollowObject = player
		#player.global_position = SPAWN_POSITION
		#camera.global_position = player.global_position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if cameraFollowObject != null:
		if cameraIsFollowing == true:
			var pos_delta: Vector2 = camera.global_position - player.global_position
			var transform: Vector2 = pos_delta * cameraFollowSpeed * delta
			camera.global_position -= transform
		else:
			#var pos_delta: Vector2 = camera.global_position - cameraAnchor
			#pos_delta.x = int(pos_delta.x)
			#pos_delta.y = int(pos_delta.y)
			#var transform: Vector2 = pos_delta * cameraFollowSpeed * delta
			#camera.global_position -= transform
			#print("lerp")
			camera.global_position = lerp(camera.global_position, cameraAnchor, 1.01 - pow(0.025, delta))
	else:
		cameraFollowObject = player
		player.global_position = SPAWN_POSITION
		camera.global_position = player.global_position
