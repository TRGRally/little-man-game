extends PlayerState

func EnterState():
	Name = "WallSlide"
	

func ExitState():
	pass
	
	
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
	else:
		Player.sprite.flip_h = false
