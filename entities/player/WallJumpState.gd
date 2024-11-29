extends PlayerState

func EnterState():
	Name = "WallJump"
	if Player.velocity.y > Player.WALL_JUMP_SPEED:
		#-y is up, player is travelling slower than wall jump
		Player.velocity.y = Player.WALL_JUMP_SPEED
	else:
		#keep y speed if theyre already travelling upward
		Player.velocity.y = Player.velocity.y
	Player.velocity.x = Player.WALL_JUMP_KICKBACK_SPEED * (-1 * Player.wallVector.x)
	
	

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
