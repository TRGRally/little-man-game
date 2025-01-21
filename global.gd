extends Node

var inputAlphabet: Array[StringName] = InputMap.get_actions().filter(func(action): return not action.begins_with("ui_"))
var tapeAlphabet: Array[StringName]

var frameCounter: int = 0
var inputsThisFrame: Array[StringName] = []

#Array of tuple(string, int) but that doesnt exist in gdscript so its an array of arrays
var inputHistory: Array[Array]


var saveData: Dictionary = {}

var allLevels: Dictionary

#the default for when there is no saved run to resume
var STARTING_LEVEL: String = "dev_level"

func saveToFile() -> void:
	var saveFile = FileAccess.open("user://save_data.json", FileAccess.WRITE)
	if saveFile:
		saveFile.store_string(JSON.stringify(saveData))
		saveFile.close()
	else:
		print("Failed to save data.")

func loadFromFile() -> void:
	var saveFile = FileAccess.open("user://save_data.json", FileAccess.READ)
	if saveFile:
		var content = saveFile.get_as_text()
		saveFile.close()
		
		var json = JSON.new()
		var parsed = json.parse(content)
		
		if parsed == OK: #crazy int code
			saveData = json.data
		else:
			print("error parsing save data: ", json.error_string, " - line ", json.error_line)
			saveData = {}
	else:
		print("no save file found: starting with default save data")
		saveData = {}
		
		
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



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#construct + and - inputs from the input alphabet
	for action in inputAlphabet:
		var pressedAction = "+" + action
		var releasedAction = "-" + action
		tapeAlphabet.append(StringName(pressedAction))
		tapeAlphabet.append(StringName(releasedAction))
	
	
	#loads the savedata into globally accessible saveData dictionary
	loadFromFile()
	
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
	
	
func _input(event) -> void:
	
	if event is InputEventMouseMotion:
		return
	
	for action in inputAlphabet:
		if event.is_action_pressed(action):
			var tapeAction = StringName("+" + action)
			inputsThisFrame.append(tapeAction)
			
		if event.is_action_released(action):
			var tapeAction = StringName("-" + action)
			inputsThisFrame.append(tapeAction)
			
	
	if event.is_action_pressed("menu"):
		print("menu pressed")
		get_tree().change_scene_to_file("res://scenes/title_screen.tscn")



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
#we track physics process in here to know what game frame we're on. for input recording.
func _physics_process(delta: float) -> void:
	frameCounter = Engine.get_physics_frames()
	if inputsThisFrame.size() == 0:
		return
	
	var symbol = [inputsThisFrame, frameCounter]
	inputHistory.append(symbol)
	inputsThisFrame = []
	print(symbol)
		
		
		
	
	
