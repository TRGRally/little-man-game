extends PlayerState

signal enter_state
signal exit_state

func EnterState():
	Name = "DuckWalk"
	enter_state.emit()

func ExitState():
	exit_state.emit()
	
	
func Draw():
	pass


func Update(delta: float):
	#handle movements
	HandleDuck()
	Player.HandleFalling()
	Player.HandleJump()
	HandleMovement(delta)
	HandleAnimations()
	HandleIdle()
	
func HandleIdle():
	if (Player.inputVector.x == 0):
		if Input.is_action_pressed("move_down"):
			Player.ChangeState(States.Duck)
		else:
			Player.ChangeState(States.Idle)

func HandleMovement(delta):
	if Player.inputVector.x != 0:
		Player.velocity.x += Player.inputVector.x * Player.SPEED

func HandleDuck():
	if not Input.is_action_pressed("move_down"):
		Player.ChangeState(States.Walk)	
	
	
func HandleAnimations():
	Player.sprite.animation = "duck_walk"
