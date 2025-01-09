extends GPUParticles2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.top_level = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_dash_enter_state(dashVector: Vector2) -> void:
	var direction = dashVector.normalized()
	self.process_material.direction = Vector3(dashVector.x, dashVector.y, 0)
	self.emitting = true


func _on_dash_exit_state() -> void:
	self.emitting = false
