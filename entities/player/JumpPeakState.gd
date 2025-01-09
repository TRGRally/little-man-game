extends PlayerState

func EnterState():
	Name = "JumpPeak"
	

func ExitState():
	pass
	
	
func Draw():
	pass
	

func Update(_delta: float):
	HandleAnimations()
	#prank the state machine by making this state transitive.
	#makes the next state's previousState be THIS state's previousState
	Player.currentState = Player.previousState
	print("-> Jump peaked")
	Player.ChangeState(States.Fall)
	
	

func HandleAnimations():
	Player.sprite.animation = "jump_down"
