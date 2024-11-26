extends PlayerState

func EnterState():
	Name = "Duck"
	

func ExitState():
	pass
	
	
func Draw():
	pass
	

func Update(delta: float):
	Player.HandleFalling()
	Player.HandleJump()
	HandleDuck()
	#Player.HorizontalMovement() not implemented
	if (Player.inputVector.x != 0):
		Player.ChangeState(States.Walk)
	HandleAnimations()
	
func HandleDuck():
	if not Input.is_action_pressed("move_down"):
		Player.ChangeState(States.Idle)	

func HandleAnimations():
	Player.sprite.animation = "duck"
