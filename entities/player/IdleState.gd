extends PlayerState

const LANDING_ANIMATION_LENGTH = 8
var landingFrames = 0
var landingSoundPlayed = false

var firstFrame = true

func EnterState():
	Name = "Idle"
	Player.removeDashHighlight()
	Player.maxSpeedThisJump = 0
	if Player.previousState == States.Fall:
		print("setting landing frames to zero")
		landingFrames = 0
		landingSoundPlayed = false

func ExitState():
	firstFrame = true
	
	
func Draw():
	pass
	

func Update(_delta: float):
	
	if (Player.inputVector.x != 0):
		if Input.is_action_pressed("move_down"):
			Player.ChangeState(States.DuckWalk)
		else:
			print("-> Movement pressed when idle, change to walk")
			Player.ChangeState(States.Walk)
			
	if not firstFrame:
		#print("[movement] applying friction Idle")
		Player.HandleFriction()
	else:
		print("SKIPPING FRICTION")
		
	Player.HandleJump()
	
	#insane race condition where HandleJump switches to jump and this logic still continues
	if Player.currentState == States.Idle:
		HandleDuck()
		HandleFalling()
		
	
	
	HandleAnimations()
	
	landingFrames += 1
	
	if firstFrame == true:
		firstFrame = false
	
func HandleDuck():
	if Input.is_action_pressed("move_down"):
		Player.ChangeState(States.Duck)	
	
	
func HandleFalling():
	if !Player.is_on_floor():
			Player.HandleFalling()
		
	
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
