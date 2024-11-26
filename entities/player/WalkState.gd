extends PlayerState

func EnterState():
	Name = "Walk"
	
	%WalkParticles.emitting = true

func ExitState():
	%WalkParticles.emitting = false
	
	
func Draw():
	pass


func Update(delta: float):
	#handle movements
	Player.HandleFalling()
	Player.HandleJump()
	HandleMovement(delta)
	HandleAnimations()
	HandleIdle()
	
func HandleIdle():
	if (Player.inputVector == Vector2.ZERO):
		Player.ChangeState(States.Idle)

func HandleMovement(delta):
	if Player.inputVector.x != 0:
		Player.velocity.x += Player.inputVector.x * Player.SPEED

	
	
func HandleAnimations():
	Player.sprite.animation = "walk"
