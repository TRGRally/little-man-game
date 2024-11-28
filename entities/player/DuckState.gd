extends PlayerState



func EnterState():
	Name = "Duck"


func ExitState():
	pass
	
	
func Draw():
	pass


func Update(delta: float):
	#handle movements
	Player.HandleFalling()
	Player.HandleJump()
	HandleDuck()
	HandleMovement(delta)
	HandleAnimations()
	HandleIdle()
	
func HandleIdle():
	if (Player.inputVector == Vector2.ZERO):
		Player.ChangeState(States.Idle)

func HandleMovement(delta):
	if Player.inputVector.x != 0:
		Player.ChangeState(States.DuckWalk)

func HandleDuck():
	if not Input.is_action_pressed("move_down"):
		if Player.inputVector.x == 0:
			Player.ChangeState(States.Idle)	
		else:
			Player.ChangeState(States.Walk)
	
	
func HandleAnimations():
	Player.sprite.animation = "duck"
