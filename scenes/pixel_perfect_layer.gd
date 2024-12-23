extends CanvasLayer
class_name PixelPerfectLayer

@export var main_camera: Camera2D
@export var pp_camera: Camera2D

@export var canvas_width = 640
@export var canvas_height = 360

@onready var sub_viewport: SubViewport = $SubViewport

func _ready() -> void:
	await get_tree().process_frame
	
	var pixel_perfect_stuff: Array = get_tree().get_nodes_in_group("PP")
	for thing in pixel_perfect_stuff:
		thing.call_deferred("reparent", sub_viewport, true)
		

func _process(delta: float) -> void:
	
	if !pp_camera or !main_camera: return
	#multiplier from main window to pixel perfect window
	var resolutionRatio = DisplayServer.screen_get_size().x / canvas_width
	#print(resolutionRatio)
	
	var newSpeed = main_camera.position_smoothing_speed / resolutionRatio
	#print(newSpeed)
	pp_camera.set_global_transform(main_camera.get_global_transform())
	
