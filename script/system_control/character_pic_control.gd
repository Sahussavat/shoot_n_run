extends Node

var character_name = ""
var text_rect
var path = "res://img/visual_characters/%s.png"
var is_playing_face = false
# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group(GroupsName.CHAR_PIC)
	text_rect = get_text_rect(self)

func get_text_rect(obj):
	var children = obj.get_children()
	for child in children:
		if child is TextureRect:
			return child
	return null

func load_default_char_face():
	var pic_path = path % (character_name).to_lower()
	if ResourceLoader.exists(pic_path):
		text_rect.texture = ResourceLoader.load(pic_path)

func load_feel_char_face(feel):
	var pic_path = path % (character_name + "_" + feel).to_lower()
	if ResourceLoader.exists(pic_path):
		text_rect.texture = ResourceLoader.load(pic_path)

func hurt():
	if not is_playing_face:
		is_playing_face = true
		load_feel_char_face("hurt")
		var default_x = text_rect.global_position.x
		for i in range(0,5):
			if i%2==0:
				text_rect.global_position.x = default_x - 5
			else:
				text_rect.global_position.x = default_x + 5
			await get_tree().create_timer(0.1).timeout
		text_rect.global_position.x = default_x
		load_default_char_face()
		is_playing_face = false


