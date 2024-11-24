extends CharacterBody2D

#fake
const MOVE_SPEED = 140.0
const DASH_JUMP_MOVE_SPEED = DASH_SPEED

const SPEED = 25.0
const AIR_SPEED = 10.0
const JUMP_SPEED = -300.0
const DASH_JUMP_SPEED = -250.0

const AIR_FRICTION = 0.99
const FRICTION = 0.85
const GRAVITY = 900
const FALL_GRAVITY = 1200
const WALL_SLIDE_SPEED = 100
const DASH_SPEED = 400
const DASH_GRAVITY = 0
const DASH_FRICTION = 0
const DASH_TIME_S = 0.1

var dashCount = 0
var allowedDashes = 1

var inputVector = Vector2.ZERO

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
		print("state changed from " + previousState.Name + " to " + currentState.Name)


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
	if currentState == States.Dash:
		return false
	if dashCount >= allowedDashes:
		return false
	return true
	
#regular gravity unless specified
func HandleGravity(delta, gravity = GRAVITY):
	if not is_on_floor():
		if not currentState == States.Dash:
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
	
	if (!is_on_floor()):
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
			


func HandleJump():
	if (is_on_floor() and Input.is_action_just_pressed("jump")):
		dashCount = 0
		if currentState == States.Dash:
			ChangeState(States.DashJump)
		else:
			ChangeState(States.Jump)
		
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
		
		
	if not currentState == States.Dash:
		if not is_on_floor():
			velocity.x = velocity.x * AIR_FRICTION
		else:
			velocity.x = velocity.x * FRICTION
		
	#Dash
	if Input.is_action_just_pressed("dash") and is_dash_available():
		ChangeState(States.Dash)
		$DashTimer.start()
	
	if is_on_floor() and not currentState == States.Dash:
		dashCount = 0
			
	HUD.set_velocity(velocity)
	wishdir = sign(inputVector.x)
	HUD.set_direction(wishdir)
	
	$DebugText.text = currentState.Name
		
	
	move_and_slide()


func _on_dash_timer_timeout() -> void:
	#avoids race condition where dash ends after jumping and triggers falling too soon
	if currentState == States.Dash:
		ChangeState(States.Fall)
