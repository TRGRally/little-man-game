extends PlayerState

func EnterState():
	Name = "Jump"
	Player.velocity.y = Player.JUMP_SPEED
	

func ExitState():
	pass
	
	
func Draw():
	pass
	

func Update(delta: float):
	Player.HandleGravity(delta)
	HandleMovement()
	HandleJumpToFall()
	Player.HandleWall()
	HandleAnimations()
	
func HandleMovement():
	if Player.inputVector.x != 0:
		Player.velocity.x += Player.inputVector.x * Player.SPEED
	
func HandleJumpToFall():
	if (Player.velocity.y >= 0):
		Player.ChangeState(States.JumpPeak)
	
func HandleAnimations():
	pass
	#not implemented
