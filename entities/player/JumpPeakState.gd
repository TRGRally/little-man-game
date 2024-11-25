extends PlayerState

func EnterState():
	Name = "JumpPeak"
	

func ExitState():
	pass
	
	
func Draw():
	pass
	

func Update(delta: float):
	#prank the state machine by making this state transitive.
	#makes the next state's previousState be THIS state's previousState
	Player.currentState = Player.previousState
	Player.ChangeState(States.Fall)
	

func HandleAnimations():
	pass
	#not implemented
