extends GPUParticles2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.top_level = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func _on_dash_jump_enter_state(dashVector: Vector2) -> void:
	self.emitting = true


func _on_dash_jump_exit_state() -> void:
	self.emitting = false
