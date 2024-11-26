extends CharacterBody2D

#fake
const MOVE_SPEED = 140.0
const DASH_JUMP_MOVE_SPEED = DASH_SPEED

const SPEED = 25.0
const AIR_SPEED = 15.0
const JUMP_SPEED = -300.0
const WALL_JUMP_SPEED = 200.0
const VARIABLE_JUMP_MULTIPLIER = 0.7
const JUMP_BUFFER_TIME_S = 0.15
const DASH_JUMP_SPEED = -250.0
const COYOTE_TIME_S = 0.15
	
const AIR_FRICTION = 0.99
const FRICTION = 0.85
const GRAVITY = 900
const FALL_GRAVITY = 1200
const MAX_FALL_SPEED = 450
const FAST_FALL_SPEED_MULTIPLIER = 1.5
const FAST_FALL_GRAVITY_MULTIPLIER = 1.2
const WALL_SLIDE_SPEED = 100
const DASH_SPEED = 400
const DASH_GRAVITY = 0
const DASH_FRICTION = 0
const DASH_TIME_S = 0.1
const DASH_BUFFER_TIME_S = 0.04

var dashCount = 0
var allowedDashes = 1

var inputVector = Vector2.ZERO
var facingVector = Vector2.ZERO
var wishdir = sign(inputVector.x)


#state machine stuff
@onready var States = $StateMachine
var currentState = null
var previousState = null
func ChangeState(newState):
	if (newState != null):
		previousState = currentState
		currentState = newState
		previousState.ExitState()
		currentState.EnterState()
		print(previousState.Name + " -> " + currentState.Name)
		return


@onready var HUD = %HUD


# Export variable to easily adjust the hitbox size in the Inspector
@export var normal_hitbox_size: Vector2 = Vector2(24, 48)
@export var normal_hitbox_transform: Vector2 = Vector2(0, -24)
@export var shrunk_hitbox_size: Vector2 = Vector2(24, 24)
@export var shrunk_hitbox_transform: Vector2 = Vector2(0, -12)

# Reference to the CollisionShape2D node
var hitbox_shape: RectangleShape2D
var hitbox: CollisionShape2D

func _ready():
	hitbox = $CollisionShape2D
	hitbox_shape = $CollisionShape2D.shape as RectangleShape2D
	
	#init statemachine
	for state in States.get_children():
		state.States = States
		state.Player = self
	#easy default to get to the ground
	previousState = States.Fall
	currentState = States.Fall

#animations not implemented
func _draw():
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
		return
		
	#resets y to active otherwise
	facingVector.y = activeDirection.y
	
		
	
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
		if not is_on_wall_only():
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
		
func HandleWall():
	if not is_on_wall_only():
		return
		
	if Input.is_action_pressed("grab"):
		ChangeState(States.WallGrab)
		return
		
	if currentState != States.WallSlide:
		if Input.is_action_pressed("move_right") or Input.is_action_pressed("move_left"):
			ChangeState(States.WallSlide)
		
	
func HandleLanding():
	if (is_on_floor()):
		ChangeState(States.Idle)

func _physics_process(delta: float) -> void:
	
	currentState.Update(delta)
	
	if Input.is_action_pressed("move_down"):
		#fucked up nested if cause move_down should be the switch
		if is_on_floor():
			$Sprite2D.animation = "duck"
			hitbox_shape.size = shrunk_hitbox_size
			hitbox.position = shrunk_hitbox_transform
	else:
		$Sprite2D.animation = "idle"
		hitbox_shape.size = normal_hitbox_size
		hitbox.position = normal_hitbox_transform
	
	

	var horizontalDirection := Input.get_axis("move_left", "move_right")
	var verticalDirection := Input.get_axis("move_up", "move_down")
	
	
	inputVector.x = horizontalDirection
	inputVector.y = verticalDirection

	# Handle jump.
	HandleJump()
		
		
	if not (currentState == States.Dash or currentState == States.DashBuffer):
		if not is_on_floor():
			velocity.x = velocity.x * AIR_FRICTION
		else:
			velocity.x = velocity.x * FRICTION
		
	#Dash
	if Input.is_action_just_pressed("dash") and is_dash_available():
		ChangeState(States.DashBuffer)
		
	
	if is_on_floor() and not (currentState == States.Dash or currentState == States.DashBuffer):
		dashCount = 0
			
	HUD.set_velocity(velocity)
	wishdir = sign(inputVector.x)
	HUD.set_direction(wishdir)
	
	HandleDirection()
	
	$DebugText.text = str(facingVector) + " " + currentState.Name
	
	if not currentState == States.DashBuffer:
		move_and_slide()


func _on_dash_timer_timeout() -> void:
	#avoids race condition where dash ends after jumping and triggers falling too soon
	if currentState == States.Dash:
		ChangeState(States.Fall)
