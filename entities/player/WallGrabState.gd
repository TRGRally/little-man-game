extends PlayerState

func EnterState():
	Name = "WallGrab"
	
	Player.velocity.y = 0
	Player.velocity.x = 0

func ExitState():
	pass
	
	
func Draw():
	pass
	

func Update(delta: float):
	Player.velocity.y = 0
	Player.HandleFalling()
	Player.HandleFriction()
	HandleAnimations()
	

func HandleAnimations():
	Player.sprite.animation = "wall_grab"
	if Player.wallVector.x < 0:
		Player.sprite.flip_h = true
	else:
		Player.sprite.flip_h = false
