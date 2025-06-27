extends PlayerState

func EnterState():
	Name = "WallGrab"
	
	Player.velocity.y = 0
	Player.velocity.x = 0
	
	if Player.wallVector.x < 0:
		var grabPosBottom = Player.rc_bottomLeft.get_collision_point()
		var grabPosTop = Player.rc_topLeft.get_collision_point()
		
		#check top then bottom then fail
		if grabPosTop:
			Player.position.x = grabPosTop.x
			#Player.position.y += 1
		elif grabPosBottom:
			Player.position.x = grabPosBottom.x
			#Player.position.y += 1
		else:
			print("FUCK :sob:")
			
		
	else:
		var grabPosBottom = Player.rc_bottomRight.get_collision_point()
		var grabPosTop = Player.rc_topRight.get_collision_point()
		
		#check top then bottom then fail
		if grabPosTop:
			Player.position.x = grabPosTop.x
			#Player.position.y += 1
		elif grabPosBottom:
			Player.position.x = grabPosBottom.x
			#Player.position.y += 1
		else:
			print("FUCK :sob:")
		
	
		
	

func ExitState():
	Player.sprite.offset.x = 0
	
	
func Draw():
	pass
	

func Update(_delta: float):
	Player.velocity.y = 0
	Player.HandleWallJump()
	Player.HandleFalling()
	Player.HandleFriction()
	HandleAnimations()
	

func HandleAnimations():
	Player.sprite.animation = "wall_grab"
	if Player.wallVector.x < 0:
		Player.sprite.offset.x = -1
		Player.sprite.flip_h = true
	else:
		Player.sprite.offset.x = 1
		Player.sprite.flip_h = false
