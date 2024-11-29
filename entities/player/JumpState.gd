extends PlayerState

func EnterState():
	Name = "Jump"
	Player.velocity.y = Player.JUMP_SPEED
	
	

func ExitState():
	pass
	
	
func Draw():
	pass
	

func Update(delta: float):
	Player.HandleGravity(delta)
	Player.HandleAirMovement(delta, Player.MOVE_SPEED)
	HandleJumpToFall()
	Player.HandleWall()
	Player.HandleFriction()
	HandleAnimations()

	
func HandleJumpToFall():
	if not Input.is_action_pressed("jump"):
		Player.velocity.y *= Player.VARIABLE_JUMP_MULTIPLIER
		Player.ChangeState(States.JumpPeak)
	
	if Player.velocity.y >= 0:
		Player.ChangeState(States.JumpPeak)
		
	
func HandleAnimations():
	Player.sprite.animation = "jump_up"
