extends PlayerState

signal enter_state
signal exit_state

const LANDING_ANIMATION_LENGTH = 8
var landingFrames = 0
var landingSoundPlayed = false

var firstFrame = true

func EnterState():
	enter_state.emit()
	
	Name = "Walk"
	
	if Player.previousState == States.Fall:
		landingFrames = 0
		landingSoundPlayed = false

func ExitState():
	firstFrame = true
	exit_state.emit()
	
	
func Draw():
	pass

func Update(delta: float):
	#print("Walk Update")
	#handle movements
	HandleDuck()
	Player.HandleFalling()
	Player.HandleJump()
	HandleMovement(delta)
	
	if not firstFrame:
		#print("[movement] applying friction Walk")
		Player.HandleFriction()
	else:
		print("SKIPPING FRICTION")
		
	HandleAnimations()
	HandleIdle()
	
	landingFrames += 1
	
	if firstFrame == true:
		firstFrame = false
	
	
func HandleIdle():
	if (Player.inputVector == Vector2.ZERO):
		Player.ChangeState(States.Idle)

func HandleMovement(_delta):
	if Player.inputVector.x != 0:
		Player.velocity.x += Player.inputVector.x * Player.SPEED

func HandleDuck():
	if Input.is_action_pressed("move_down"):
		Player.ChangeState(States.DuckWalk)	
	
	
func HandleAnimations():
	if landingFrames <= LANDING_ANIMATION_LENGTH:
		if landingSoundPlayed == false:
			landingSoundPlayed = true
			Player.load_sfx(Player.sfx_landing)
			
	
	#if Player.wallDirection
	Player.sprite.animation = "walk"
