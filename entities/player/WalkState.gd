extends PlayerState

func EnterState():
	Name = "Walk"
	

func ExitState():
	pass
	
	
func Draw():
	pass


func Update(delta: float):
	#handle movements
	Player.HandleFalling()
	Player.HandleJump()
	HandleMovement()
	HandleAnimations()
	HandleIdle()
	
func HandleIdle():
	if (Player.inputVector == Vector2.ZERO):
		Player.ChangeState(States.Idle)

func HandleMovement():
	if Player.inputVector.x != 0:
		Player.velocity.x += Player.inputVector.x * Player.SPEED

	
	
func HandleAnimations():
	pass
	#not implemented
