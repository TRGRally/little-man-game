extends GPUParticles2D

var doJumpFrame = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.top_level = true
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if doJumpFrame:
		doJumpFrame = false
		self.emitting = true
	else:
		self.emitting = false
		
	#print(str(doJumpFrame))



func _on_wall_jump_enter_state(lastWall: Vector2) -> void:
	if lastWall.x > 0:
		doJumpFrame = true

func _on_wall_jump_exit_state(lastWall: Vector2) -> void:
	doJumpFrame = false
