extends CharacterBody2D
class_name Player

var rng = RandomNumberGenerator.new()

@onready var HighlightShader = preload("res://entities/player/color replace.gdshader")
@onready var SmoothPixelShader = preload("res://scenes/smoothpixel.gdshader")


const MOVE_SPEED: float = 140.0
const DASH_JUMP_MOVE_SPEED: float = DASH_SPEED
const MAX_BOOST_SPEED: float = 400.0

const SPEED: float = 25.0
const AIR_SPEED: float = 20.0
const JUMP_SPEED: float = -300.0
const WALL_JUMP_SPEED: float = -300.0
const WALL_JUMP_KICKBACK_SPEED: float = 250.0
const VARIABLE_JUMP_MULTIPLIER: float = 0.5
const VARIABLE_WALLJUMP_MULTIPLIER: float = 0.85
const JUMP_BUFFER_TIME_S: float = 0.15
const DASH_JUMP_SPEED: float = -250.0
const COYOTE_TIME_S: float = 0.15
const DASH_COYOTE_TIME_S: float = 0.1

const AIR_FRICTION: float = 0.99
const FRICTION: float = 0.85
const GRAVITY: float = 900.0
const FALL_GRAVITY: float = 1200.0
const MAX_FALL_SPEED: float = 400.0
const FAST_FALL_SPEED_MULTIPLIER: float = 1.2
const FAST_FALL_GRAVITY_MULTIPLIER: float = 1.3
const WALL_SLIDE_SPEED: float = 100.0
const DASH_SPEED: float = 400.0
const DASH_GRAVITY: float = 0.0
const DASH_FRICTION: float = 0.0
const DASH_TIME_S: float = 0.1
const DASH_BUFFER_TIME_S: float = 0.04

const ROOM_LOCKED_TIME_S: float = 0.5

#model
const MIDPOINT_OFFSET: int = -16
var hitboxes = {
	"default": PackedVector2Array([Vector2(6,12), Vector2(-6,12), Vector2(-6,-12), Vector2(6,-12)]),
	"fall_coersion": PackedVector2Array([Vector2(6,12), Vector2(-6,12), Vector2(-6,0), Vector2(0,-12), Vector2(6,0)]),
	"air_coersion": PackedVector2Array([Vector2(0,12), Vector2(-6,0), Vector2(0,-12), Vector2(6,0)]),
	"shrunk": PackedVector2Array([Vector2(6,12), Vector2(-6,12), Vector2(-6,0), Vector2(6,0)])
}
var normal_hitbox_shape: PackedVector2Array = PackedVector2Array([Vector2(6,12), Vector2(-6,12), Vector2(-6,-12), Vector2(6,-12)])
var fall_coersion_hitbox_shape: PackedVector2Array = PackedVector2Array([Vector2(6,12), Vector2(-6,12), Vector2(-6,0), Vector2(0,-12), Vector2(6,0)])
var air_coersion_hitbox_shape: PackedVector2Array = PackedVector2Array([Vector2(0,12), Vector2(-6,0), Vector2(0,-12), Vector2(6,0)])
var shrunk_hitbox_shape: PackedVector2Array = PackedVector2Array([Vector2(6,12), Vector2(-6,12), Vector2(-6,0), Vector2(6,0)])


var currentHitboxName = "default"

func changeHitbox(newHitboxName):
	if currentHitboxName == newHitboxName:
		return
		
	print("[hitbox] " + str(newHitboxName))
	hitbox_shape.set_point_cloud(hitboxes[newHitboxName])
	currentHitboxName = newHitboxName
	

@export var sfx_dash: Array[AudioStream]
@export var sfx_footsteps: Array[AudioStream]
@export var sfx_landing: Array[AudioStream]
@export var sfx_jump: Array[AudioStream]

#when to play footstep sounds in the walk animation
var walk_footstep_frames: Array[int] = [3, 7]

var dashCount: int = 0
var allowedDashes: int = 1

var previousPositionVector: Vector2 = Vector2.ZERO

var inputVector: Vector2 = Vector2.ZERO
var facingVector: Vector2 = Vector2.ZERO
var dashVector: Vector2 = Vector2.ZERO
var wallVector: Vector2 = Vector2.ZERO
var lastWall: Vector2 = Vector2.ZERO
var wishdir: int = sign(inputVector.x)
var canUnDuck: bool = false
var canStartCoyoteTime: bool = true

var wallSpeedRetained: float = 0.0

var externalForce: Vector2 = Vector2.ZERO

#debug
var maxSpeedThisJump: float = 0.0




func load_sfx(sfx_to_load: Array):
	#picks one sound from that category to play (e.g. one footstep of many)
	var index = (rng.randi_range(1, sfx_to_load.size())) - 1

	#creates a new AudioStreamPlayer to allow for overlapping different sound effects
	var newAudioStream: Node = AudioStreamPlayer.new()
	add_child(newAudioStream)
	newAudioStream.bus = "Player"
	newAudioStream.stream = sfx_to_load[index]
	newAudioStream.play()
	
	#if %SFXPlayer.stream != sfx_to_load[index]:
		#%SFXPlayer.stream = sfx_to_load[index]


#combat related variables
var maxHealth: int = 5
var startingHealth: int = maxHealth

var currentHealth: int = startingHealth

func damage(amount):
	var newHealth = currentHealth - amount
	var alive = false
	if newHealth > 0:
		currentHealth = newHealth
		alive  = true
	else:
		currentHealth = 0
		#kill the player idk
		alive = false
	
	return alive
		


#state machine stuff
@onready var States: Node = $StateMachine
var currentState: PlayerState = null
var previousState: PlayerState = null

func ChangeState(newState: PlayerState):
	if (newState != null and newState != currentState):
		previousState = currentState
		currentState = newState
		previousState.ExitState()
		currentState.EnterState()
		print(previousState.Name + " -> " + currentState.Name)
		return
	else:
		print("erroneous state change: " + currentState.name + " -> " + newState.Name)
		return


@onready var HUD: CanvasLayer = %HUD
@onready var sprite = $Sprite2D
@onready var rc_bottomLeft: RayCast2D = $Raycasts/WallJump/BottomLeft
@onready var rc_topLeft: RayCast2D = $Raycasts/WallJump/TopLeft
@onready var rc_bottomRight: RayCast2D = $Raycasts/WallJump/BottomRight
@onready var rc_topRight: RayCast2D = $Raycasts/WallJump/TopRight
@onready var rc_duckRight: RayCast2D = $Raycasts/Duck/TopRight
@onready var rc_duckLeft: RayCast2D = $Raycasts/Duck/TopLeft

@onready var DashParticles: GPUParticles2D = %DashParticles
@onready var DashJumpParticles: GPUParticles2D = %DashJumpParticles
@onready var WalkParticles: GPUParticles2D = %WalkParticles
@onready var JumpParticles: GPUParticles2D = %JumpParticles
@onready var WallSlideLeftParticles: GPUParticles2D = %WallSlideLeftParticles
@onready var WallSlideRightParticles: GPUParticles2D = %WallSlideRightParticles
@onready var WallJumpLeftParticles: GPUParticles2D = %WallJumpLeftParticles
@onready var WallJumpRightParticles: GPUParticles2D = %WallJumpRightParticles



# Reference to the CollisionShape2D node
var hitbox_shape: ConvexPolygonShape2D
var hitbox: CollisionShape2D

func _ready():
	hitbox = $CollisionShape2D
	hitbox_shape = $CollisionShape2D.shape as ConvexPolygonShape2D
	
	#raycast exceptions
	rc_bottomLeft.add_exception(self)
	rc_topLeft.add_exception(self)
	rc_bottomRight.add_exception(self)
	rc_topRight.add_exception(self)
	
	
	#init statemachine
	for state in States.get_children():
		state.States = States
		state.Player = self
	#easy default to get to the ground
	previousState = States.Fall
	currentState = States.Fall
	
	$Sprite2D.autoplay

#animations not implemented
func _draw():
	print("drawing")
	currentState.Draw()

func is_dash_available():
	if currentState == States.Dash or currentState == States.DashBuffer:
		return false
	if dashCount >= allowedDashes:
		return false
	return true
	

func dashHighlight():
	sprite.material.shader = HighlightShader
	sprite.material.set_shader_parameter("masque", Vector3(0.4, 0.85, 1.0))
	sprite.texture_filter = 1
	
func dashBufferHighlight():
	sprite.material.shader = HighlightShader
	sprite.material.set_shader_parameter("masque", Vector3(1.0, 1.0, 1.0))
	sprite.texture_filter = 1
	
	
func removeDashHighlight():
	sprite.material.shader = SmoothPixelShader
	sprite.texture_filter = 0

	
func HandleDirection():
	#both Vector2(x,y)
	var activeDirection = inputVector
	var passiveDirection = Vector2(sign(velocity.x), sign(velocity.y))
	var prevDirection = facingVector
	
	#separately assign x and y so they dont overwrite each other
	if activeDirection.x != 0:
		facingVector.x = activeDirection.x
	else:
		facingVector.x = prevDirection.x
	#y should only persist in dash or dash buffering
	if currentState == States.Dash or currentState == States.DashBuffer:
		#individial movement direction is pressed, favour orthogonal over diagonal
		if abs(activeDirection.x) != abs(activeDirection.y):
			facingVector = activeDirection
	else:	
		#resets y to active otherwise
		facingVector.y = activeDirection.y
		
	
	HUD.set_facing_direction(facingVector)
		
	
#regular gravity unless specified
func HandleGravity(delta, gravity = GRAVITY, maxFallSpeed = MAX_FALL_SPEED):
	#crazy function parameter mutation but idc rn
	if inputVector.y > 0:
		maxFallSpeed *= FAST_FALL_SPEED_MULTIPLIER
		gravity *= FAST_FALL_GRAVITY_MULTIPLIER
	
	if not is_on_floor():
		if not (currentState == States.Dash or currentState == States.DashBuffer):
			var newvel = velocity.y + (gravity * delta)
			if newvel >= maxFallSpeed:
				velocity.y = maxFallSpeed
			else:
				velocity.y += gravity * delta	
		
	
func HandleFalling():
	if currentState == States.WallSlide:
		if not (Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right")):
			print("-> Player released slide input on wall")
			ChangeState(States.Fall)
		if wallVector == Vector2.ZERO:
			print("-> wallVector is zero")
			ChangeState(States.Fall)
		return
	
	if currentState == States.WallGrab:
		if not Input.is_action_pressed("grab"):
			print("-> Player let go of wall")
			ChangeState(States.Fall)
		return
		
	#standard falling off ledge check
	if (!is_on_floor()):
		%CoyoteTimer.start(COYOTE_TIME_S)
		print("started coyote timer")
		print("-> Standard falling off ledge check, started coyote timer. " + currentState.Name + " from " + previousState.Name)
		ChangeState(States.Fall)

func HandleDashFloor():
	
	#you dont "fall" off a ledge in dash but we still need to check if the player has
	#stopped contacting the ground to apply coyote time
	if (!is_on_floor() and canStartCoyoteTime):
		print("dash coyote start")
		canStartCoyoteTime = false
		%CoyoteTimer.start(DASH_COYOTE_TIME_S)

func HandleAirMovement(delta, allowedSpeed):
	if inputVector.x != 0:
		#runs movement calculation and checks if it would help the player change directions, 
		#if not, dont apply the new velocity
		var currentdir = sign(velocity.x)
		
		if abs(velocity.x) < allowedSpeed:
			#they are currently moving slower than the allowed move_speed so accelerate
			velocity.x += inputVector.x * AIR_SPEED
			return
		
		if currentdir != wishdir:
			#they want to change direction so let them turn
			velocity.x += inputVector.x * AIR_SPEED
		


func HandleJumpBuffer():
	if %JumpBuffer.time_left > 0:
		pass
		#print(%JumpBuffer.time_left)
	if Input.is_action_just_pressed("jump"):
		print("jump buffer started")
		%JumpBuffer.start(JUMP_BUFFER_TIME_S)
	#they must have jump pressed when landing to use their jump buffer
	if not Input.is_action_pressed("jump"):
		if %JumpBuffer.time_left > 0:
			print("jump buffer cancelled")
			%JumpBuffer.stop()
		

func HandleJump():
	if (is_on_floor()):
		#jump either just pressed or buffered previously
		if (%JumpBuffer.time_left > 0 or Input.is_action_just_pressed("jump")):
			if %JumpBuffer.time_left > 0 and not Input.is_action_just_pressed("jump"):
				print("BUFFERED JUMP")
			%JumpBuffer.stop()
			dashCount = 0
			if currentState == States.Dash:
				if dashVector.x != 0:
					ChangeState(States.DashJump)
				else: 
					return
			elif currentState == States.DashBuffer:
				ChangeState(States.DashJump)
			else:
				ChangeState(States.Jump)
	else:
		#jump pressed shortly after falling off a ledge (coyote time)
		if %CoyoteTimer.time_left > 0:
			if Input.is_action_just_pressed("jump"):
				%CoyoteTimer.stop()
				dashCount = 0
				if currentState == States.Dash or currentState == States.DashBuffer:
					ChangeState(States.DashJump)
					print("coyote time dash jump")
				else:
					ChangeState(States.Jump)
					print("coyote time jump")
				

func isUnDuckSafe():
	if rc_duckLeft.is_colliding() or rc_duckRight.is_colliding():
		return false
	else:
		return true

func GetWallDirection():
	if rc_bottomRight.is_colliding() or rc_topRight.is_colliding():
		wallVector = Vector2.RIGHT
	elif rc_bottomLeft.is_colliding() or rc_topLeft.is_colliding():
		wallVector = Vector2.LEFT
	else:
		wallVector = Vector2.ZERO
	#print(str(rc_bottomLeft.get_collider()) + " " + str(rc_bottomRight.get_collider()))
		
func HandleWall():
	if wallVector != Vector2.ZERO:
		if Input.is_action_pressed("grab") and currentState != States.WallGrab and velocity.y >= 0:
			ChangeState(States.WallGrab)
			return
	
		if inputVector.x == wallVector.x and velocity.y > 0:
			if currentState != States.WallSlide:
				ChangeState(States.WallSlide)
		

func HandleWallJump():
	if currentState != States.WallJump and wallVector != Vector2.ZERO:
		if %JumpBuffer.time_left > 0 or Input.is_action_just_pressed("jump"):
			%JumpBuffer.stop()
			ChangeState(States.WallJump)

func HandleLanding():
	if (is_on_floor()):
		ChangeState(States.Idle)
		
		
func HandleFriction():
	if not is_on_floor():
		velocity.x = velocity.x * AIR_FRICTION
	else:
		velocity.x = velocity.x * FRICTION
	
func GetRoundedPosition(atFeet = false):
	if atFeet:
		return Vector2(round(position.x), round(position.y))
	else:
		return Vector2(round(position.x), round(position.y + MIDPOINT_OFFSET))
		
		
func InputOrLookDirection():
	if inputVector != Vector2.ZERO:
		dashVector = inputVector
	else:
		dashVector = facingVector
	
#runs every frame not every physics tick (variable interval)
func _process(delta) -> void:
	#floor to the nearest whole number
	
	# UNSECURED CANDIDATE
	# - toletoletole
	
	# its funnier the secoind time
	
	# trolle ttrolle
	
	#wtf man
	
	#quantises the sprite position to the pixel grid
	var midpointVector = GetRoundedPosition()
	var feetVector = GetRoundedPosition(true)
	
	sprite.global_position = midpointVector
	DashParticles.global_position = midpointVector
	DashJumpParticles.global_position = midpointVector
	WalkParticles.global_position = feetVector
	JumpParticles.global_position = feetVector
	WallJumpLeftParticles.global_position = Vector2(midpointVector.x - 7, midpointVector.y)
	WallJumpRightParticles.global_position = Vector2(midpointVector.x + 7, midpointVector.y)
	WallSlideLeftParticles.global_position = Vector2(midpointVector.x - 6, midpointVector.y)
	WallSlideRightParticles.global_position = Vector2(midpointVector.x + 6, midpointVector.y)

#runs every physics tick (fixed interval)
func _physics_process(delta: float) -> void:
	#wall direction calculated at start so states use frame correct value
	GetWallDirection()
	
	HandleJumpBuffer()
		
	canUnDuck = isUnDuckSafe()

	if currentState != States.Duck and currentState != States.DuckWalk and currentState != States.Dash and currentState != States.DashJump:
		#print("[hitbox] in state to change hitbox")
		if canUnDuck == true:
			#print("[hitbox] canUnDuck == true")
			if is_on_floor():
				#print("[hitbox] is_on_floor(): normal_hitbox_shape")
				changeHitbox("default")
			else:
				if currentState == States.WallGrab or currentState == States.WallSlide:
					#print("[hitbox] WallGrab or WallSlide: normal_hitbox_shape")
					changeHitbox("default")
				elif velocity.y < 0:
					#print("[hitbox] velocity < 0: wall_coersion_hitbox_shape")
					changeHitbox("air_coersion")
				else:
					#print("[hitbox] else: air_coersion_hitbox_shape")
					changeHitbox("fall_coersion")
					
					
	if is_dash_available():
		removeDashHighlight()
			
		
	#update the sprite facing direction if in a state that allows turning
	#TODO: refactor to use multiple lists of states that allow different things
	if currentState != States.Dash and currentState != States.WallGrab and currentState != States.WallSlide:
		if facingVector.x < 0:
			sprite.flip_h = true
		else:
			sprite.flip_h = false
		
		
	
	
	
	currentState.Update(delta)
	
	#Dash
	if Input.is_action_just_pressed("dash") and is_dash_available():
		print("DASHING")
		ChangeState(States.DashBuffer)	
	
	#health
	HUD.set_health(currentHealth)
	
	
	var horizontalDirection := Input.get_axis("move_left", "move_right")
	var verticalDirection := Input.get_axis("move_up", "move_down")
	
	inputVector.x = sign(horizontalDirection)
	inputVector.y = sign(verticalDirection)
	
	InputOrLookDirection()

	
	if is_on_floor() and not (currentState == States.Dash or currentState == States.DashBuffer):
		dashCount = 0
			
	
	wishdir = sign(inputVector.x)
	HUD.set_input_direction(wishdir)
	
	HandleDirection()
	
	
	previousPositionVector = global_position
	#run physics
	if not currentState == States.DashBuffer and not currentState == States.Locked:
		
		if velocity.length() < MAX_BOOST_SPEED or velocity.dot(externalForce) < 0:
			velocity += externalForce
			
		HUD.set_velocity(velocity)
		$DebugText.text = currentState.Name
		if abs(velocity.x) > maxSpeedThisJump:
			maxSpeedThisJump = abs(velocity.x)
			HUD.set_max_speed(maxSpeedThisJump)
		
		move_and_slide()
	else:
		pass
		#print("vel in buffer = " + str(velocity.length()) + " " + str(velocity)) 
	
	
	



func _on_dash_timer_timeout() -> void:
	#avoids race condition where dash ends after jumping and triggers falling too soon
	if currentState == States.Dash:
		if is_on_floor():
			if inputVector.x != 0:
				if inputVector.y > 0:
					ChangeState(States.DuckWalk)
				else:
					print("-> Dash timer timeout, change to walk")
					ChangeState(States.Walk)
			else:
				if inputVector.y > 0:
					ChangeState(States.Duck)
				else:
					ChangeState(States.Idle)
		else:
			ChangeState(States.Fall)


func _on_sprite_2d_frame_changed() -> void:
	if sprite.animation != "walk": return
	 
	
	if sprite.frame in walk_footstep_frames: 
		load_sfx(sfx_footsteps)
		#%SFXPlayer.play()


func _on_dash_buffer_enter_state() -> void:
	load_sfx(sfx_dash)
	#%SFXPlayer.play()
	
	

func _on_jump_enter_state() -> void:
	load_sfx(sfx_jump)
	#%SFXPlayer.play()


func _on_dash_jump_enter_state(_dashVector: Vector2) -> void:
	load_sfx(sfx_jump)
	#%SFXPlayer.play()


func _on_locked_timer_timeout() -> void:
	if currentState == States.Locked:
		ChangeState(previousState)


func _on_wall_jump_enter_state(_lastWall) -> void:
	print("WALL JUMPING")
	load_sfx(sfx_jump)
