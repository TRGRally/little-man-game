extends PlayerState


func EnterState():
	Name = "DashBuffer"
	#starts the buffer countdown on state entry
	%DashBuffer.start(Player.DASH_BUFFER_TIME_S)

func ExitState():
	#Player.inputVectorBuffer = inputVectorBuffer
	pass
	
func Draw():
	pass
	

func Update(delta: float):
	pass
	
	

func HandleAnimations():
	pass
	#not implemented


func _on_dash_buffer_timeout() -> void:
	if Player.currentState == States.DashBuffer:
		Player.ChangeState(States.Dash)