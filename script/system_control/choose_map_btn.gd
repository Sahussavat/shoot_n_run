extends Node

var map_path = "res://nodes/worlds/"

enum m_index {
	MAP_NAME,
	MAP_NODE_NAME,
	MAP_IMG_PATH,
}

var maps = [
	{
		m_index.MAP_NAME: "Untitiled 1",
		m_index.MAP_NODE_NAME: "world",
		m_index.MAP_IMG_PATH: "res://img/Parallax Clouds Pack by Captainskeleto/Parallax10.png",
	},
	{
		m_index.MAP_NAME: "Untitiled 2",
		m_index.MAP_NODE_NAME: "shop",
		m_index.MAP_IMG_PATH: "res://img/Parallax Clouds Pack by Captainskeleto/Parallax10.png",
	},
	{
		m_index.MAP_NAME: "Untitiled 3",
		m_index.MAP_NODE_NAME: "world",
		m_index.MAP_IMG_PATH: "res://img/Parallax Clouds Pack by Captainskeleto/Parallax10.png",
	},
]

@onready var prev_btn = $VBoxContainer/HBoxContainer/prev
@onready var next_btn = $VBoxContainer/HBoxContainer/next
@onready var map_title = $VBoxContainer/map_name
@onready var map_img = $VBoxContainer/HBoxContainer/image
@onready var start_btn = $VBoxContainer/start

var map_index = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	start_btn.pressed.connect(start_map)
	prev_btn.pressed.connect(prev_map)
	next_btn.pressed.connect(next_map)
	show_choose_map()

func start_map():
	ChangePage.change_to_target_scene(get_node_path(maps[map_index][m_index.MAP_NODE_NAME]))

func show_choose_map():
	prev_btn.visible = map_index > 0
	next_btn.visible = map_index < maps.size() - 1
	var m = maps[map_index]
	map_title.text = m[m_index.MAP_NAME]
	map_img.texture = load(m[m_index.MAP_IMG_PATH])

func next_map():
	map_index = clampi(map_index + 1, 0, maps.size() - 1)
	show_choose_map()

func prev_map():
	map_index = clampi(map_index - 1, 0, maps.size() - 1)
	show_choose_map()

func get_node_path(map_node_name : String):
	return map_path + map_node_name + ".tscn"
