extends PlayerState

signal emit_left_particles
signal emit_right_particles
signal stop_left_particles
signal stop_right_particles

func EnterState():
	Name = "WallSlide"
	

func ExitState():
	stop_left_particles.emit()
	stop_right_particles.emit()
	
	
func Draw():
	pass
	

func Update(delta: float):
	Player.HandleLanding()
	Player.HandleFalling()
	Player.HandleWallJump()
	Player.HandleWall()
	HandleMovement()
	HandleSliding(delta)
	Player.HandleFriction()
	HandleAnimations()


func HandleMovement():
	if Player.inputVector.x != 0:
		Player.velocity.x += Player.inputVector.x * Player.SPEED	

func HandleSliding(delta):
	if Player.velocity.y >= Player.WALL_SLIDE_SPEED:
		Player.velocity.y = Player.WALL_SLIDE_SPEED
	else:
		Player.HandleGravity(delta)
	
	

func HandleAnimations():
	Player.sprite.animation = "wall_slide"
	if Player.wallVector.x < 0:
		Player.sprite.flip_h = true
		if Player.currentState == States.WallSlide:
			emit_left_particles.emit()
			stop_right_particles.emit()
	else:
		Player.sprite.flip_h = false
		if Player.currentState == States.WallSlide:
			stop_left_particles.emit()
			emit_right_particles.emit()
