extends PlayerState

signal enter_state
signal exit_state

var canUnDuck = false

func EnterState():
	Name = "DuckWalk"
	enter_state.emit()

func ExitState():
	exit_state.emit()
	
	
func Draw():
	pass


func Update(delta: float):
	
	Player.changeHitbox("shrunk")
	
	canUnDuck = Player.canUnDuck
		
	#handle movements
	HandleDuck()
	Player.HandleFalling()
	Player.HandleJump()
	HandleMovement(delta)
	Player.HandleFriction()
	HandleAnimations()
	HandleIdle()
	
func HandleIdle():
	if (Player.inputVector.x == 0):
			
			if canUnDuck == true and not Player.inputVector.y < 0:
				Player.ChangeState(States.Idle)
			else:
				Player.ChangeState(States.Duck)

func HandleMovement(delta):
	if Player.inputVector.x != 0:
		Player.velocity.x += Player.inputVector.x * Player.SPEED

func HandleDuck():
	if canUnDuck == true:
		if not Input.is_action_pressed("move_down"):
			if Player.inputVector.x == 0:
				print("-> Unducking and still, change to idle")
				Player.ChangeState(States.Idle)
			else:
				print("-> Unducking and moving, change to walk")
				Player.ChangeState(States.Walk)	
		
	
func HandleAnimations():
	Player.sprite.animation = "duck_walk"
