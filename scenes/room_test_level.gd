extends Node2D

@export var player: CharacterBody2D
@export var HUD: CanvasLayer
@export var camera: Camera2D

var SPAWN_POSITION = Vector2(0,0)

var cameraFollowObject: Node2D
var cameraFollowSpeed: float = 6.0
var cameraIsFollowing = true
var cameraAnchor: Vector2 = Vector2(0,0)

#dict of Vector2(x,y) -> bool (inside/outside)
var cameraAnchorCollisionMap: Dictionary

func set_camera_anchor(anchor, transitionLockState):
	cameraAnchor = anchor
	cameraIsFollowing = false
	player.ChangeState(player.States.Locked)
	
func release_camera_anchor(transitionLockState):#
	var stillHaveAnchor = false
	var foundAnchor = Vector2(0,0)
	for anchor in cameraAnchorCollisionMap.keys():
		if cameraAnchorCollisionMap[anchor] == 1:
			stillHaveAnchor = true
			foundAnchor = anchor
		
	if stillHaveAnchor:
		cameraAnchor = foundAnchor
		pass
	else:
		cameraIsFollowing = true
		player.ChangeState(player.States.Locked)
	
func camera_anchor_body_entered(body, binds):
	var area = binds[0]
	print(area)
	if body == player:
		cameraAnchorCollisionMap[area.anchor] = 1
		set_camera_anchor(area.anchor, area.transitionLockState)

func camera_anchor_body_exited(body, binds):
	var area = binds[0]
	if body == player:
		cameraAnchorCollisionMap[area.anchor] = 0
		release_camera_anchor(area.transitionLockState)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var cameraLockAreas = get_tree().get_nodes_in_group("CameraLockAreas")
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
