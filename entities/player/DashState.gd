extends PlayerState

func EnterState():
	Name = "Dash"
	
	Player.dashCount = Player.dashCount + 1
	if Player.velocity.length() <= Player.DASH_SPEED:
		Player.velocity = Player.DASH_SPEED * Player.inputVector
	else:
		Player.velocity = Player.velocity.length() * Player.inputVector
	

func ExitState():
	pass
	
	
func Draw():
	pass
	

func Update(delta: float):
	pass
	

func HandleAnimations():
	pass
	#not implemented
