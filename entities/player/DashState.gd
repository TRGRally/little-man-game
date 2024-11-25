extends PlayerState

func EnterState():
	Name = "Dash"
	%DashTimer.start()
	%DashParticles.emitting = true
	
	var directionRaw = InputOrLookDirection()
	var direction = directionRaw.normalized()
	
	Player.dashCount = Player.dashCount + 1
	
	if Player.is_on_floor():
		Player.velocity = Player.DASH_SPEED * directionRaw
	else:
		Player.velocity = Player.DASH_SPEED * direction
	

func ExitState():
	%DashParticles.emitting = false
	
	
func Draw():
	pass
	

func Update(delta: float):
	Player.HandleJumpBuffer()
	
	
func InputOrLookDirection():
	if Player.inputVector != Vector2.ZERO:
		return Player.inputVector
	else:
		return Player.facingVector

func HandleAnimations():
	pass
	#not implemented
