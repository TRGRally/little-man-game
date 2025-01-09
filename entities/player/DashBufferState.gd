extends PlayerState

signal enter_state
signal exit_state

func EnterState():
	Name = "DashBuffer"
	enter_state.emit()
	#starts the buffer countdown on state entry
	%DashBuffer.start(Player.DASH_BUFFER_TIME_S)
	
	Player.dashBufferHighlight()
	#Player.dashStamps()
	

func ExitState():
	#Player.inputVectorBuffer = inputVectorBuffer
	exit_state.emit()

	
func Draw():
	pass
	

func Update(_delta: float):
	HandleAnimations()
	Player.HandleJump()
	
	

func HandleAnimations():
	#Player.sprite.animation = "dash"
	pass


func _on_dash_buffer_timeout() -> void:
	if Player.currentState == States.DashBuffer:
		Player.ChangeState(States.Dash)
