extends PlayerState

signal enter_state
signal exit_state

func EnterState():
	enter_state.emit()
	
	Name = "Dash"
	%DashTimer.start()
	
	var directionRaw = InputOrLookDirection()
	var direction = directionRaw.normalized()
	
	Player.dashCount = Player.dashCount + 1
	
	if Player.is_on_floor() and direction.y > 0:
		Player.velocity = Player.DASH_SPEED * directionRaw
	else:
		Player.velocity = Player.DASH_SPEED * direction
	

func ExitState():
	exit_state.emit()
	
	
func Draw():
	pass
	

func Update(delta: float):
	Player.HandleJumpBuffer()
	HandleAnimations()
	
	
func InputOrLookDirection():
	if Player.inputVector != Vector2.ZERO:
		return Player.inputVector
	else:
		return Player.facingVector

func HandleAnimations():
	Player.sprite.animation = "dash"
