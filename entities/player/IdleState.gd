extends PlayerState

const LANDING_ANIMATION_LENGTH = 8
var landingFrames = 0

func EnterState():
	Name = "Idle"
	if Player.previousState == States.Fall:
		landingFrames = 0

func ExitState():
	pass
	
	
func Draw():
	pass
	

func Update(delta: float):
	Player.HandleFalling()
	Player.HandleJump()
	
	if (Player.inputVector.x != 0):
		if Input.is_action_pressed("move_down"):
			Player.ChangeState(States.DuckWalk)
		else:
			Player.ChangeState(States.Walk)
			
	if landingFrames != 0:
		Player.HandleFriction()
			
	HandleDuck()
	HandleAnimations()
	
	landingFrames += 1
	
func HandleDuck():
	if Input.is_action_pressed("move_down"):
		Player.ChangeState(States.Duck)	
	
	
func HandleAnimations():
	if landingFrames <= LANDING_ANIMATION_LENGTH:
		Player.sprite.animation = "land"
	else:
		Player.sprite.animation = "idle"
