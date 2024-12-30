extends PlayerState

const LANDING_ANIMATION_LENGTH = 8
var landingFrames = 0
var landingSoundPlayed = false

func EnterState():
	Name = "Idle"
	Player.removeDashHighlight()
	Player.maxSpeedThisJump = 0
	if Player.previousState == States.Fall:
		landingFrames = 0
		landingSoundPlayed = false

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
		if landingSoundPlayed == false:
			landingSoundPlayed = true
			Player.load_sfx(Player.sfx_landing)
			%SFXPlayer.play()
			
	else:
		if Player.canUnDuck == true:
			Player.sprite.animation = "idle"
		else:
			Player.sprite.animation = "duck"
