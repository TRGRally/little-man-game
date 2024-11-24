extends PlayerState

func EnterState():
	Name = "DashJump"
	Player.velocity.y = Player.DASH_JUMP_SPEED
	
	

func ExitState():
	pass
	
	
func Draw():
	pass
	

func Update(delta: float):
	Player.HandleGravity(delta)
	Player.HandleAirMovement(delta, Player.DASH_JUMP_MOVE_SPEED)
	HandleJumpToFall()
	Player.HandleWall()
	HandleAnimations()

	
func HandleJumpToFall():
	if (Player.velocity.y >= 0):
		Player.ChangeState(States.JumpPeak)
	
func HandleAnimations():
	pass
	#not implemented
