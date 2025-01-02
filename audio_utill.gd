extends Node

var master_volume = 1
var bgm_volume = 1
var se_volume = 1
var save_file_path = "user://volume.save"
@onready var bgm_audio
# Called when the node enters the scene tree for the first time.

func load_volume():
	if FileAccess.file_exists(save_file_path):
		var volume_save_file = FileAccess.open(save_file_path, FileAccess.READ)
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
			master_volume = data["master_volume"]
			bgm_volume = data["bgm_volume"]
			se_volume = data["se_volume"]
			set_master_volume_scale(master_volume)

func save_volume_data():
	var volume_save_file = FileAccess.open(save_file_path, FileAccess.WRITE)
	volume_save_file.store_line(JSON.stringify({
		"master_volume": master_volume,
		"bgm_volume": bgm_volume,
		"se_volume": se_volume,
	}))

func play_se_sound(sound_name, target = get_tree().current_scene):
	var sound_path = get_file_se_path(sound_name)
	if ResourceLoader.exists(sound_path):
		var a = ResourceLoader.load(sound_path)
		var se_audio = AudioStreamPlayer.new()
		target.add_child(se_audio)
		se_audio.stream = a
		se_audio.set_volume_db(linear_to_db(se_volume))
		se_audio.add_to_group(GroupsName.SE)
		se_audio.finished.connect(func():
			se_audio.queue_free()
			)
		if is_inside_tree():
			se_audio.play()

func get_bgm_sound():
	if not bgm_audio:
		bgm_audio = AudioStreamPlayer2D.new()
		bgm_audio.name = "bgm_sound"
		bgm_audio.add_to_group(GroupsName.BGM)
		get_tree().current_scene.add_child(bgm_audio)
	return bgm_audio

func play_bgm(sound_name):
	var sound_path = get_file_bgm_path(sound_name)
	if ResourceLoader.exists(sound_path):
		var a = ResourceLoader.load(sound_path)
		get_bgm_sound().stream = a
		get_bgm_sound().set_volume_db(linear_to_db(bgm_volume))
		if get_bgm_sound().is_inside_tree():
			get_bgm_sound().play()

func get_file_bgm_path(file_name):
	return get_file_path("bgm/%s.mp3" % (file_name).to_lower())

func get_file_se_path(file_name):
	return get_file_path("se/%s.mp3" % (file_name).to_lower())

func get_file_path(file_name):
	return "res://sounds/" + file_name

func set_master_volume_scale(scale):
	master_volume = scale
	set_bgm_volume_scale()
	set_se_volume_scale()

func set_bgm_volume_scale(scale = bgm_volume):
	bgm_volume = scale
	save_volume_data()
	get_tree().call_group(GroupsName.BGM, "set_volume_db", linear_to_db(scale * master_volume))

func set_se_volume_scale(scale = se_volume):
	se_volume = scale
	save_volume_data()
	get_tree().call_group(GroupsName.SE, "set_volume_db", linear_to_db(scale * master_volume))


