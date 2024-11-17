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
	Player.HandleWall()
	HandleMovement()
	HandleSliding(delta)


func HandleMovement():
	if Player.inputVector.x != 0:
		Player.velocity.x += Player.inputVector.x * Player.SPEED	

func HandleSliding(delta):
	if Player.velocity.y >= Player.WALL_SLIDE_SPEED:
		Player.velocity.y = Player.WALL_SLIDE_SPEED
	else:
		Player.HandleGravity(delta)
	
	

func HandleAnimations():
	pass
	#not implemented
