extends GPUParticles2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.top_level = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_wall_slide_emit_right_particles() -> void:
	self.emitting = true


func _on_wall_slide_stop_right_particles() -> void:
	self.emitting = false
