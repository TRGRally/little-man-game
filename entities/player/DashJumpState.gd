extends PlayerState

func EnterState():
	Name = "DashJump"
	#diagonal down dash jump goes less high to account for the fact the movement vector isnt normalised
	#this lets the player choose distance at the cost of height
	if (Player.inputVector.y > 0):
		Player.velocity.y = Player.DASH_JUMP_SPEED
	else:
		Player.velocity.y = Player.JUMP_SPEED
	
	if Player.inputVector.x != 0:
		Player.velocity.x = max(abs(Player.velocity.x), Player.inputVector.length() * Player.DASH_SPEED) * Player.inputVector.x
	else:
		Player.velocity.x = max(abs(Player.velocity.x), Player.facingVector.length() * Player.DASH_SPEED) * Player.facingVector.x

	print(str(Player.velocity.x))

func ExitState():
	pass
	
	
func Draw():
	pass
	

func Update(delta: float):
	Player.HandleGravity(delta)
	Player.HandleAirMovement(delta, Player.DASH_JUMP_MOVE_SPEED)
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
	Player.sprite.animation = "jump_up"
