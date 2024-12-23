extends PlayerState

signal enter_state
signal exit_state

func EnterState():
	enter_state.emit(Player.dashVector)
	
	Name = "Dash"
	%DashTimer.start()
	
	var directionRaw: Vector2 = Player.dashVector
	var direction: Vector2 = directionRaw.normalized()
	
	Player.hitbox_shape.set_point_cloud(Player.shrunk_hitbox_shape)
	
	Player.dashCount = Player.dashCount + 1
	
	if Player.is_on_floor() and direction.y > 0:
		if direction.dot(Player.velocity.normalized()) > 0 and Player.velocity.length() > Player.DASH_SPEED:
			Player.velocity = Player.velocity.length() * directionRaw
		else:
			Player.velocity = Player.DASH_SPEED * directionRaw
	else:
		if direction.dot(Player.velocity.normalized()) > 0 and Player.velocity.length() > Player.DASH_SPEED:
			Player.velocity = Player.velocity.length() * direction
		else:
			Player.velocity = Player.DASH_SPEED * direction
	

func ExitState():
	exit_state.emit()
	
	
func Draw():
	pass
	

func Update(delta: float):
	Player.HandleJumpBuffer()
	Player.HandleDashFloor()
	HandleAnimations()
	

func HandleAnimations():
	Player.sprite.animation = "dash"
