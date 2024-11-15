extends PlayerState

func EnterState():
	Name = "Idle"
	

func ExitState():
	pass
	
	
func Draw():
	pass
	

func Update(delta: float):
	Player.HandleFalling()
	Player.HandleJump()
	#Player.HorizontalMovement() not implemented
	if (Player.inputVector != Vector2.ZERO):
		Player.ChangeState(States.Walk)
	HandleAnimations()
	
func HandleAnimations():
	pass
	#not implemented
