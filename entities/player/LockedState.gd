extends PlayerState


func EnterState():
	Name = "Locked"
	%LockedTimer.start(Player.ROOM_LOCKED_TIME_S)
	

func ExitState():
	pass
	
	
func Draw():
	pass
	

func Update(_delta: float):
	pass
	
