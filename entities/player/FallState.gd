extends PlayerState


func EnterState():
	Name = "Fall"
	if Player.previousState == States.Dash:
		pass

func ExitState():
	pass
	
	
func Draw():
	pass
	

func Update(delta: float):
	Player.HandleGravity(delta, Player.FALL_GRAVITY)
	#we handle jump before checking for landing to allow the player to get a perf hop
	Player.HandleJump()
	Player.HandleJumpBuffer()
	Player.HandleLanding()
	Player.HandleAirMovement(delta, Player.MOVE_SPEED)
	
	Player.HandleWall()
	HandleAnimations()
	
	

func HandleAnimations():
	pass
	#not implemented
