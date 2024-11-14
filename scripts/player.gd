extends CharacterBody2D


const SPEED = 50.0
const AIR_SPEED = 20.0
const JUMP_VELOCITY = -600.0
const AIR_FRICTION = 0.95
const FRICTION = 0.8
const GRAVITY = 2000
const FALL_GRAVITY = 2400
const DASH_VELOCITY = 600
const DASH_GRAVITY = 0
const DASH_FRICTION = 0
const DASH_TIME_S = 0.2

var isDashing = false
var dashCount = 0
var allowedDashes = 1

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
	


func is_dash_available():
	if isDashing:
		return false
	if dashCount >= allowedDashes:
		return false
	return true
	

func _physics_process(delta: float) -> void:
	
	if Input.is_action_pressed("move_down"):
		#fucked up nested if cause move_down should be the switch
		if is_on_floor():
			$Sprite2D.animation = "duck"
			hitbox_shape.size = shrunk_hitbox_size
			hitbox.position = shrunk_hitbox_transform
	else:
		$Sprite2D.animation = "default"
		hitbox_shape.size = normal_hitbox_size
		hitbox.position = normal_hitbox_transform
	
	# Add the gravity.
	if not is_on_floor():
		if not isDashing:
			velocity.y += GRAVITY * delta

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var horizontalDirection := Input.get_axis("move_left", "move_right")
	var verticalDirection := Input.get_axis("move_up", "move_down")
	
	var inputVector = Vector2.ZERO
	inputVector.x = horizontalDirection
	inputVector.y = verticalDirection

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y += JUMP_VELOCITY
		dashCount = 0
		
	
	if horizontalDirection:
		if is_on_floor():
			velocity.x += inputVector.x * SPEED
		else:
			velocity.x += inputVector.x * AIR_SPEED

		
	
	if not is_on_floor():
		velocity.x = velocity.x * AIR_FRICTION
	else:
		if not isDashing:
			velocity.x = velocity.x * FRICTION
		
	#Dash
	if Input.is_action_just_pressed("dash") and is_dash_available():
		isDashing = true
		dashCount = dashCount + 1
		
		$DashTimer.start()
		
		if velocity.length() <= DASH_VELOCITY:
			velocity = DASH_VELOCITY * inputVector
		else:
			velocity = velocity.length() * inputVector
	
	if is_on_floor() and not isDashing:
		dashCount = 0
			
			
	HUD.set_velocity(velocity)
	
		
	
	move_and_slide()


func _on_dash_timer_timeout() -> void:
	isDashing = false
