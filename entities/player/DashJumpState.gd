extends PlayerState

func EnterState():
	Name = "DashJump"
	Player.velocity.y = Player.DASH_JUMP_SPEED
	Player.velocity.x = max(abs(Player.velocity.x), Player.inputVector.length() * Player.DASH_SPEED) * Player.inputVector.x
	print(str(Player.velocity.x))

func ExitState():
	pass
	
	
func Draw():
	pass
	

func Update(delta: float):
	Player.HandleGravity(delta)
	#Player.HandleAirMovement(delta, Player.DASH_JUMP_MOVE_SPEED)
	HandleJumpToFall()
	Player.HandleWall()
	HandleAnimations()

	
func HandleJumpToFall():
	if not Input.is_action_pressed("jump"):
		Player.velocity.y *= Player.VARIABLE_JUMP_MULTIPLIER
		Player.ChangeState(States.JumpPeak)
	
	if Player.velocity.y >= 0:
		Player.ChangeState(States.JumpPeak)
	
func HandleAnimations():
	pass
	#not implemented
