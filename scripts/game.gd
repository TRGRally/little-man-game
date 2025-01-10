extends Node2D

@onready var HUD = %HUD
@onready var camera = %PlayerCamera
@onready var player = $Player
	

var STARTING_LEVEL = "dev_level"
var levelInstance = null

var allLevels: Dictionary

#returns list of files at given path recursivelys
func get_all_files(path: String, file_ext := "", files : Array[String] = []) -> Array[String]:
	var dir : = DirAccess.open(path)
	if file_ext.begins_with("."): # get rid of starting dot if we used, for example ".tscn" instead of "tscn"
		file_ext = file_ext.substr(1,file_ext.length()-1)
	
	if DirAccess.get_open_error() == OK:
		dir.list_dir_begin()

		var file_name = dir.get_next()

		while file_name != "":
			if dir.current_is_dir():
				# recursion
				files = get_all_files(dir.get_current_dir() +"/"+ file_name, file_ext, files)
			else:
				if file_ext and file_name.get_extension() != file_ext:
					file_name = dir.get_next()
					continue
				
				files.append(dir.get_current_dir() +"/"+ file_name)

			file_name = dir.get_next()
	else:
		print("[get_all_files()] An error occurred when trying to access %s." % path)
	return files

func changeLevel(sceneName: String):
	var scene = load(allLevels[sceneName])
	levelInstance = scene.instantiate()
	add_child(levelInstance)
	levelInstance.player = player
	levelInstance.HUD = HUD
	levelInstance.camera = camera
	print("Loaded scene: " + scene.resource_name)
	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Engine.set_time_scale(1)
	
	var allLevelPaths: Array[String] = get_all_files("res://scenes/levels", "tscn")
	print(allLevelPaths)
	#shove it in nice dict
	for path in allLevelPaths:
		print(path)
		var levelNameFull = path.get_slice("/", path.get_slice_count("/") - 1)
		var levelName = levelNameFull.trim_suffix(".tscn")
		print(levelName)
		allLevels[levelName] = path
	
	print(str(allLevels))
	changeLevel(STARTING_LEVEL)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _physics_process(delta: float) -> void:
	pass

	
