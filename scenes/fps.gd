extends Label

var tps: int = 0
var fps: float = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _physics_process(delta: float) -> void:
	tps = Engine.physics_ticks_per_second
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	fps = Engine.get_frames_per_second()
	text = "FPS " + str(fps) + " (PHYS " + str(tps) + ")"
