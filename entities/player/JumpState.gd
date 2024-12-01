extends PlayerState

signal enter_state
signal exit_state

const JUMP_PARTICLE_FRAMES = 0
var currentFrame = 0

func EnterState():
	Name = "Jump"
	enter_state.emit()
	Player.velocity.y = Player.JUMP_SPEED
	currentFrame = 0
	

func ExitState():
	exit_state.emit()
	
	
func Draw():
	pass
	

func Update(delta: float):
	Player.HandleGravity(delta)
	Player.HandleAirMovement(delta, Player.MOVE_SPEED)
	HandleJumpToFall()
	Player.HandleWall()
	Player.HandleWallJump()
	Player.HandleFriction()
	HandleAnimations()
	
	currentFrame += 1

	
func HandleJumpToFall():
	if not Input.is_action_pressed("jump"):
		Player.velocity.y *= Player.VARIABLE_JUMP_MULTIPLIER
		Player.ChangeState(States.JumpPeak)
	
	if Player.velocity.y >= 0:
		Player.ChangeState(States.JumpPeak)
		
	
func HandleAnimations():
	Player.sprite.animation = "jump_up"
	
	
	
