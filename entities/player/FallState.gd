extends PlayerState

const JUMP_DOWN_ANIMATION_LENGTH = 8
var fallingFrames = 0

func EnterState():
	Name = "Fall"
	#TODO: refactor as list of jumping states
	if Player.previousState == States.Jump or Player.previousState == States.DashJump or Player.previousState == States.Dash or Player.previousState == States.WallJump:
		fallingFrames = 0

func ExitState():
	Player.sprite.scale.y = 1.0
	Player.sprite.scale.x = 1.0
	
	
func Draw():
	pass
	

func Update(delta: float):
	Player.HandleGravity(delta, Player.FALL_GRAVITY)
	#we handle jump before checking for landing to allow the player to get a perf hop
	Player.HandleLanding()
	Player.HandleJump()
	Player.HandleAirMovement(delta, Player.MOVE_SPEED)
	Player.HandleFriction()
	Player.HandleWall()
	Player.HandleWallJump()
	HandleAnimations(delta)
	
	fallingFrames += 1

func HandleAnimations(delta):
	if fallingFrames <= JUMP_DOWN_ANIMATION_LENGTH:
		Player.sprite.animation = "jump_down"
	else:
		Player.sprite.animation = "fall"
	
	#if Player.velocity.y > Player.MAX_FALL_SPEED:
		#Player.sprite.scale.y = move_toward(Player.sprite.scale.y, 1.2, 1.5 * delta)
		#Player.sprite.scale.x = move_toward(Player.sprite.scale.x, 0.9, 1.5 * delta)
		#print("sprite scale:" + str(Player.sprite.scale.y))
	#else:
		#Player.sprite.scale.y = move_toward(Player.sprite.scale.y, 1.0, 1.5 * delta)
		#Player.sprite.scale.x = move_toward(Player.sprite.scale.x, 1.0, 1.5 * delta)
