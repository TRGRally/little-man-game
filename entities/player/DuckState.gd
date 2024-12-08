extends PlayerState

var canUnDuck = false

func EnterState():
	Name = "Duck"


func ExitState():
	pass
	
	
func Draw():
	pass


func Update(delta: float):
	
	Player.hitbox_shape.set_point_cloud(Player.shrunk_hitbox_shape)
	
	canUnDuck = Player.canUnDuck
	
	#handle movements
	Player.HandleFalling()
	Player.HandleJump()
	HandleDuck()
	HandleMovement(delta)
	Player.HandleFriction()
	HandleAnimations()
	HandleIdle()
	
func HandleIdle():
	if (Player.inputVector == Vector2.ZERO):
		if canUnDuck == true:
			Player.ChangeState(States.Idle)

func HandleMovement(delta):
	if Player.inputVector.x != 0:
		Player.ChangeState(States.DuckWalk)

func HandleDuck():
	if canUnDuck == true:
		if not Input.is_action_pressed("move_down"):
			if Player.inputVector.x == 0:
				Player.ChangeState(States.Idle)	
			else:
				Player.ChangeState(States.Walk)
	
	
func HandleAnimations():
	Player.sprite.animation = "duck"
