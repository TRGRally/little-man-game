extends PlayerState

signal enter_state
signal exit_state

#true = right
var flipDirection = true


const LOCK_FRAMES = 10
var currentFrames = 0
func EnterState():
	Name = "DashWallJump"
	
	currentFrames = 0
	
	Player.lastWall = Player.wallVector
	
	if Player.velocity.y > Player.WALL_JUMP_SPEED:
		#-y is up, player is travelling slower than wall jump
		Player.velocity.y = Player.WALL_JUMP_SPEED
	else:
		#keep y speed if theyre already travelling upward
		Player.velocity.y = Player.velocity.y
	Player.velocity.x = Player.WALL_JUMP_KICKBACK_SPEED * (-1 * Player.wallVector.x)
	
	
	if Player.lastWall.x > 0:
		flipDirection = true
		Player.facingVector.x = -1
	else:
		flipDirection = false
		Player.facingVector.x = 1
	
	
	

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

	currentFrames += 1
	
func HandleJumpToFall():
	if not Input.is_action_pressed("jump"):
		Player.velocity.y *= Player.VARIABLE_JUMP_MULTIPLIER
		Player.ChangeState(States.JumpPeak)
	
	if Player.velocity.y >= 0:
		Player.ChangeState(States.JumpPeak)
		
	
func HandleAnimations():
	Player.sprite.animation = "jump_up"
	
	if currentFrames <= LOCK_FRAMES:
		#print( "flipping" + str(flipDirection))
		Player.sprite.flip_h = flipDirection
	
	
