extends PlayerState

signal enter_state
signal exit_state

const JUMP_PARTICLE_FRAMES = 0
var currentFrame = 0

var horizontalPushSpeed = 0
var preWallHorizontalSpeed = 0

func EnterState():
	Name = "DashJump"
	enter_state.emit(Player.dashVector)
	
	Player.changeHitbox("shrunk")
	
	var facingVector = Player.facingVector
	if facingVector.x == 0:
		facingVector = Vector2.RIGHT
	
	#diagonal down dash jump goes less high to account for the fact the movement vector isnt normalised
	#this lets the player choose distance at the cost of height
	if (Player.inputVector.y > 0):
		Player.velocity.y = Player.DASH_JUMP_SPEED
	else:
		Player.velocity.y = Player.JUMP_SPEED
	
	if Player.inputVector.x != 0:
		horizontalPushSpeed = max(abs(Player.velocity.x), Player.inputVector.length() * Player.DASH_SPEED) * Player.inputVector.x
		Player.velocity.x = horizontalPushSpeed
	else:
		horizontalPushSpeed = max(abs(Player.velocity.x), facingVector.length() * Player.DASH_SPEED) * facingVector.x
		Player.velocity.x = horizontalPushSpeed

	print(str(Player.velocity.x))
	
	currentFrame = 0

func ExitState():
	exit_state.emit()
	
	
func Draw():
	pass
	

func Update(delta: float):
	Player.HandleGravity(delta)
	Player.HandleAirMovement(delta, Player.DASH_JUMP_MOVE_SPEED)
	HandleJumpToFall()
	Player.HandleWall()
	Player.HandleFriction()
	HandleAnimations()
	
	
	if Player.is_on_wall_only():
		if preWallHorizontalSpeed != 0:
			Player.velocity.x = preWallHorizontalSpeed
	else:
		preWallHorizontalSpeed = Player.velocity.x
	
	currentFrame += 1

	
func HandleJumpToFall():
	if not Input.is_action_pressed("jump"):
		Player.velocity.y *= Player.VARIABLE_JUMP_MULTIPLIER
		Player.ChangeState(States.JumpPeak)
	
	if Player.velocity.y >= 0:
		Player.ChangeState(States.JumpPeak)
	
func HandleAnimations():
	if Player.dashVector.y > 0:
		Player.sprite.animation = "dash"
	else:
		Player.sprite.animation = "jump_up"
	Player.DashJumpParticles.process_material.direction = Vector3(Player.velocity.x, Player.velocity.y, 0)
