extends Node

var crypto = Crypto.new()

var key

var highest_score = 0
var score = 0
var is_turn_off_score_delta = false
var save_file_path = "user://score_%s.save"
var key_path = "user://generated.key"

var current_scene_name = ""

func _ready():
	if not FileAccess.file_exists(key_path):
		key = crypto.generate_rsa(4096)
	else:
		key.load(key_path)

func load_highest_score():
	if FileAccess.file_exists(save_file_path % current_scene_name):
		var volume_save_file = FileAccess.open(save_file_path % current_scene_name, FileAccess.READ)
		while volume_save_file.get_position() < volume_save_file.get_length():
			var json_string = volume_save_file.get_line()

			# Creates the helper class to interact with JSON.
			var json = JSON.new()

			# Check if there is any error while parsing the JSON string, skip in case of failure.
			var parse_result = json.parse(json_string)
			if not parse_result == OK:
				print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
				continue
			
			var data = json.data
			highest_score = int(data["highest_score"])
	
	return highest_score

func score_delta(delta):
	if not is_turn_off_score_delta:
		score += delta
	set_current_scene_name()

func set_current_scene_name():
	current_scene_name = get_tree().current_scene.name

func save_highest_score():
	if score > highest_score:
		highest_score = score
		var highest_score_file = FileAccess.open(save_file_path % current_scene_name, FileAccess.WRITE)
		highest_score_file.store_line(JSON.stringify({
			"highest_score": highest_score
		}))

func reset():
	score = 0
