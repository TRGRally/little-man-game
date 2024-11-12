extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const AIR_FRICTION = 0.95
const FRICTION = 0.9


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y += JUMP_VELOCITY
		
	
	

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var horizontalDirection := Input.get_axis("move_left", "move_right")
	var verticalDirection := Input.get_axis("move_up", "move_down")
	
	var inputVector = Vector2.ZERO
	inputVector.x = horizontalDirection
	inputVector.y = verticalDirection
	
	if horizontalDirection:
		velocity.x = inputVector.x * SPEED
	else:
		velocity.x = velocity.x * FRICTION
	
	if not is_on_floor():
		velocity.x = velocity.x * AIR_FRICTION
			
			
		
	
		
	
	move_and_slide()
