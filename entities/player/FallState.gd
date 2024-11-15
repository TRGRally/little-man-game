extends PlayerState

func EnterState():
	Name = "Fall"
	

func ExitState():
	pass
	
	
func Draw():
	pass
	

func Update(delta: float):
	Player.HandleGravity(delta, Player.FALL_GRAVITY)
	Player.HandleLanding()
	HandleMovement()
	HandleAnimations()
	
func HandleMovement():
	if Player.inputVector.x != 0:
		Player.velocity.x += Player.inputVector.x * Player.SPEED
	

func HandleAnimations():
	pass
	#not implemented
