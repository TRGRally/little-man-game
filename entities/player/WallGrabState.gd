extends PlayerState

func EnterState():
	Name = "WallGrab"
	
	Player.velocity.y = 0
	Player.velocity.x = 0
	

func ExitState():
	pass
	
	
func Draw():
	pass
	

func Update(delta: float):
	Player.velocity.y = 0
	Player.HandleFalling()
	
	

func HandleAnimations():
	pass
	#not implemented
