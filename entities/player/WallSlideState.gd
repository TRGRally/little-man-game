extends PlayerState

func EnterState():
	Name = "WallSlide"
	

func ExitState():
	pass
	
	
func Draw():
	pass
	

func Update(delta: float):
	Player.ChangeState(States.Fall)
	

func HandleAnimations():
	pass
	#not implemented
