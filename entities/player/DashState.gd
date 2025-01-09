extends PlayerState

signal enter_state
signal exit_state

var dashPushVector: Vector2 = Vector2.ZERO
var floorDash: bool = false

func EnterState():
	enter_state.emit(Player.dashVector)
	
	Name = "Dash"
	%DashTimer.start()
	
	var directionRaw: Vector2 = Player.dashVector
	if directionRaw == Vector2.ZERO:
		directionRaw = Vector2.RIGHT
	
	var direction: Vector2 = directionRaw.normalized()
	
	Player.changeHitbox("shrunk")
	
	#dash highlight shader
	Player.dashHighlight()
	
	Player.dashCount = Player.dashCount + 1
	
	if Player.is_on_floor():
		floorDash = true
	else:
		floorDash = false
	
	if Player.is_on_floor() and direction.y > 0:
		if direction.dot(Player.velocity.normalized()) > 0 and Player.velocity.length() > Player.DASH_SPEED:
			dashPushVector = Player.velocity.length() * directionRaw
			Player.velocity = dashPushVector
		else:
			dashPushVector = Player.DASH_SPEED * directionRaw
			Player.velocity = dashPushVector
	else:
		if direction.dot(Player.velocity.normalized()) > 0 and Player.velocity.length() > Player.DASH_SPEED and direction.y > 0:
			dashPushVector = Player.velocity.length() * direction
			Player.velocity = dashPushVector
		else:
			dashPushVector = Player.DASH_SPEED * direction
			Player.velocity = dashPushVector
			
	#dash coyote time reset
	if Player.is_on_floor() and direction.y >= 0:
		Player.canStartCoyoteTime = true
	

func ExitState():
	exit_state.emit()
	Player.canStartCoyoteTime = false
	
	
func Draw():
	pass
	

func Update(_delta: float):
	Player.HandleDashFloor()
	
	HandleAnimations()
	
	if not floorDash:
		Player.velocity = dashPushVector
		
	Player.HandleJump()
	

func HandleAnimations():
	Player.sprite.animation = "dash"
