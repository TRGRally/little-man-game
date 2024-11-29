extends PlayerState

const JUMP_DOWN_ANIMATION_LENGTH = 4
var fallingFrames = 0

func EnterState():
	Name = "Fall"
	#TODO: refactor as list of jumping states
	if Player.previousState == States.Jump or Player.previousState == States.DashJump or Player.previousState == States.Dash or Player.previousState == States.WallJump:
		fallingFrames = 0

func ExitState():
	pass
	
	
func Draw():
	pass
	

func Update(delta: float):
	Player.HandleGravity(delta, Player.FALL_GRAVITY)
	#we handle jump before checking for landing to allow the player to get a perf hop
	Player.HandleLanding()
	Player.HandleJump()
	Player.HandleJumpBuffer()
	Player.HandleAirMovement(delta, Player.MOVE_SPEED)
	Player.HandleFriction()
	Player.HandleWall()
	Player.HandleWallJump()
	HandleAnimations()
	
	fallingFrames += 1

func HandleAnimations():
	if fallingFrames <= JUMP_DOWN_ANIMATION_LENGTH:
		Player.sprite.animation = "jump_down"
	else:
		Player.sprite.animation = "fall"
