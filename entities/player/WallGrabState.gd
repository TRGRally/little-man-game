extends PlayerState

func EnterState():
	Name = "WallGrab"
	
	Player.velocity.y = 0
	Player.velocity.x = 0
	
	if Player.wallVector.x < 0:
		var grabPos = Player.rc_bottomLeft.get_collision_point()
		Player.position.x = grabPos.x
		Player.position.y += 1
	else:
		var grabPos = Player.rc_bottomRight.get_collision_point()
		Player.position.x = grabPos.x
		Player.position.y += 1
		
	

func ExitState():
	pass
	
	
func Draw():
	pass
	

func Update(delta: float):
	Player.velocity.y = 0
	Player.HandleWallJump()
	Player.HandleFalling()
	Player.HandleFriction()
	HandleAnimations()
	

func HandleAnimations():
	Player.sprite.animation = "wall_grab"
	if Player.wallVector.x < 0:
		Player.sprite.flip_h = true
	else:
		Player.sprite.flip_h = false
