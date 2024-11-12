extends CharacterBody2D


const SPEED = 30.0
const JUMP_VELOCITY = -600.0
const AIR_FRICTION = 0.95
const FRICTION = 0.85
const GRAVITY = 2000
const FALL_GRAVITY = 2400
const DASH_VELOCITY = 1000

var dashCount = 0
var allowedDashes = 1

# Export variable to easily adjust the hitbox size in the Inspector
@export var normal_hitbox_size: Vector2 = Vector2(24, 48)
@export var normal_hitbox_transform: Vector2 = Vector2(0, -24)
@export var shrunk_hitbox_size: Vector2 = Vector2(24, 24)
@export var shrunk_hitbox_transform: Vector2 = Vector2(0, -12)

# Reference to the CollisionShape2D node
var hitbox_shape: RectangleShape2D
var hitbox: CollisionShape2D

func _ready():
	# Get the shape reference from the CollisionShape2D node
	hitbox = $CollisionShape2D
	hitbox_shape = $CollisionShape2D.shape as RectangleShape2D
	


func is_dash_available():
	if dashCount >= allowedDashes:
		return false
	return true
	

func _physics_process(delta: float) -> void:
	
	if Input.is_action_pressed("move_down"):
		# Change the size to the shrunk version
		hitbox_shape.size = shrunk_hitbox_size
		hitbox.position = shrunk_hitbox_transform
	else:
		# Reset to normal size
		hitbox_shape.size = normal_hitbox_size
		hitbox.position = normal_hitbox_transform
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var horizontalDirection := Input.get_axis("move_left", "move_right")
	var verticalDirection := Input.get_axis("move_up", "move_down")
	
	var inputVector = Vector2.ZERO
	inputVector.x = horizontalDirection
	inputVector.y = verticalDirection

	# Handle jump.
	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y = JUMP_VELOCITY / 2
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y += JUMP_VELOCITY
		
	
	if horizontalDirection:
		velocity.x += inputVector.x * SPEED

		
	
	if not is_on_floor():
		velocity.x = velocity.x * AIR_FRICTION
	else:
		velocity.x = velocity.x * FRICTION
		
	#Dash
	if Input.is_action_just_pressed("dash") and is_dash_available():
		dashCount = dashCount + 1
		velocity += DASH_VELOCITY * inputVector
	
	if is_on_floor():
		dashCount = 0
			
			
		
	
		
	
	move_and_slide()
