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
	Player.HandleAirMovement(delta, Player.MOVE_SPEED)
	Player.HandleWall()
	HandleAnimations()
	
	

func HandleAnimations():
	pass
	#not implemented
