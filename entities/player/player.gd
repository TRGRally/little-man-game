extends CharacterBody2D
class_name Player

#fake
const MOVE_SPEED = 140.0
const DASH_JUMP_MOVE_SPEED = DASH_SPEED

const SPEED = 25.0
const AIR_SPEED = 15.0
const JUMP_SPEED = -300.0
const WALL_JUMP_SPEED = -300.0
const WALL_JUMP_KICKBACK_SPEED = 250.0
const VARIABLE_JUMP_MULTIPLIER = 0.55
const VARIABLE_WALLJUMP_MULTIPLIER = 0.85
const JUMP_BUFFER_TIME_S = 0.15
const DASH_JUMP_SPEED = -225.0
const COYOTE_TIME_S = 0.15
	
const AIR_FRICTION = 0.99
const FRICTION = 0.85
const GRAVITY = 900
const FALL_GRAVITY = 1200
const MAX_FALL_SPEED = 450
const FAST_FALL_SPEED_MULTIPLIER = 1.25
const FAST_FALL_GRAVITY_MULTIPLIER = 1.3
const WALL_SLIDE_SPEED = 100
const DASH_SPEED = 400
const DASH_GRAVITY = 0
const DASH_FRICTION = 0
const DASH_TIME_S = 0.1
const DASH_BUFFER_TIME_S = 0.04

#model
const MIDPOINT_OFFSET = -16
@export var normal_hitbox_shape: PackedVector2Array = PackedVector2Array([Vector2(6,12), Vector2(-6,12), Vector2(-6,-12), Vector2(6,-12)])
@export var shrunk_hitbox_shape: PackedVector2Array = PackedVector2Array([Vector2(6,12), Vector2(-6,12), Vector2(-6,0), Vector2(6,0)])


var dashCount = 0
var allowedDashes = 1

var inputVector = Vector2.ZERO
var facingVector = Vector2.ZERO
var dashVector = Vector2.ZERO
var wallVector = Vector2.ZERO
var lastWall = Vector2.ZERO
var wishdir = sign(inputVector.x)
var canUnDuck = false

#debug
var maxSpeedThisJump = 0

#combat related variables
var maxHealth = 5
var startingHealth = maxHealth

var currentHealth = startingHealth

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
@onready var States = $StateMachine
var currentState = null
var previousState = null
func ChangeState(newState):
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


@onready var HUD = %HUD
@onready var sprite = $Sprite2D
@onready var rc_bottomLeft = $Raycasts/WallJump/BottomLeft
@onready var rc_bottomRight = $Raycasts/WallJump/BottomRight
@onready var rc_duckRight = $Raycasts/Duck/TopRight
@onready var rc_duckLeft = $Raycasts/Duck/TopLeft

@onready var DashSFX = $DashSFX

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
	rc_bottomRight.add_exception(self)
	
	
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
	
func HandleDirection():
	#both Vector2(x,y)
	var activeDirection = inputVector
	var passiveDirection = Vector2(sign(velocity.x), sign(velocity.y))
	#separately assign x and y so they dont overwrite each other
	if activeDirection.x != 0:
		facingVector.x = activeDirection.x
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
			ChangeState(States.Fall)
		if wallVector == Vector2.ZERO:
			ChangeState(States.Fall)
		return
	
	if currentState == States.WallGrab:
		if not Input.is_action_pressed("grab"):
			ChangeState(States.Fall)
		return
		
	#standard falling off ledge check
	if (!is_on_floor()):
		%CoyoteTimer.start(COYOTE_TIME_S)
		ChangeState(States.Fall)


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
		#print("jump buffer started")
		%JumpBuffer.start(JUMP_BUFFER_TIME_S)
	#they must have jump pressed when landing to use their jump buffer
	if not Input.is_action_pressed("jump"):
		if %JumpBuffer.time_left > 0:
			#print("jump buffer cancelled")
			%JumpBuffer.stop()
		

func HandleJump():
	if (is_on_floor()):
		#jump either just pressed or buffered previously
		if (%JumpBuffer.time_left > 0 or Input.is_action_just_pressed("jump")):
			%JumpBuffer.stop()
			dashCount = 0
			if currentState == States.Dash or currentState == States.DashBuffer:
				ChangeState(States.DashJump)
			else:
				ChangeState(States.Jump)
	else:
		#jump pressed shortly after falling off a ledge (coyote time)
		if %CoyoteTimer.time_left > 0:
			if Input.is_action_just_pressed("jump"):
				%CoyoteTimer.stop()
				dashCount = 0
				ChangeState(States.Jump)
				print("coyote time jump")

func isUnDuckSafe():
	if rc_duckLeft.is_colliding() or rc_duckRight.is_colliding():
		return false
	else:
		return true

func GetWallDirection():
	if rc_bottomRight.is_colliding():
		wallVector = Vector2.RIGHT
	elif rc_bottomLeft.is_colliding():
		wallVector = Vector2.LEFT
	else:
		wallVector = Vector2.ZERO
	#print(str(rc_bottomLeft.get_collider()) + " " + str(rc_bottomRight.get_collider()))
		
func HandleWall():
	if wallVector != Vector2.ZERO:
		if Input.is_action_pressed("grab") and currentState != States.WallGrab:
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
	
	canUnDuck = isUnDuckSafe()

	if currentState != States.Duck or currentState != States.DuckWalk:
		if canUnDuck == true:
			hitbox_shape.set_point_cloud(normal_hitbox_shape)
		
	#update the sprite facing direction if in a state that allows turning
	#TODO: refactor to use multiple lists of states that allow different things
	if currentState != States.Dash and currentState != States.WallGrab and currentState != States.WallSlide:
		if facingVector.x < 0:
			sprite.flip_h = true
		else:
			sprite.flip_h = false
		
	currentState.Update(delta)
	
	#health
	HUD.set_health(currentHealth)
	
	
	
	
	
	var horizontalDirection := Input.get_axis("move_left", "move_right")
	var verticalDirection := Input.get_axis("move_up", "move_down")
	
	inputVector.x = horizontalDirection
	inputVector.y = verticalDirection
	
	InputOrLookDirection()

	#handle jump
	HandleJump()
		
	
		
		
	#Dash
	if Input.is_action_just_pressed("dash") and is_dash_available():
		ChangeState(States.DashBuffer)
		
	
	if is_on_floor() and not (currentState == States.Dash or currentState == States.DashBuffer):
		dashCount = 0
			
	HUD.set_velocity(velocity)
	wishdir = sign(inputVector.x)
	HUD.set_input_direction(wishdir)
	
	HandleDirection()
	
	$DebugText.text = currentState.Name
	
	if abs(velocity.x) > maxSpeedThisJump:
		maxSpeedThisJump = abs(velocity.x)
		HUD.set_max_speed(maxSpeedThisJump)
	
	
	
	#run physics
	if not currentState == States.DashBuffer:
		move_and_slide()
	else:
		print("vel in buffer = " + str(velocity.length()) + " " + str(velocity)) 
	
	
		



func _on_dash_timer_timeout() -> void:
	#avoids race condition where dash ends after jumping and triggers falling too soon
	if currentState == States.Dash:
		if is_on_floor():
			ChangeState(States.Idle)
		else:
			ChangeState(States.Fall)
