extends GPUParticles2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.top_level = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_walk_enter_state() -> void:
	self.emitting = true


func _on_walk_exit_state() -> void:
	self.emitting = false


func _on_duck_walk_enter_state() -> void:
	self.emitting = true


func _on_duck_walk_exit_state() -> void:
	self.emitting = false
