extends Node

@onready var master_v = $VBoxContainer/master/HSlider
@onready var bgm_v = $VBoxContainer/bgm/HSlider
@onready var se_v = $VBoxContainer/se/HSlider
# Called when the node enters the scene tree for the first time.
func _ready():
	AudioUtill.load_volume()
	master_v.value = AudioUtill.master_volume
	bgm_v.value = AudioUtill.bgm_volume
	se_v.value = AudioUtill.se_volume
	master_v.value_changed.connect(set_master_v)
	bgm_v.value_changed.connect(set_bgm_v)
	se_v.value_changed.connect(set_se_v)

func set_master_v(value):
	AudioUtill.set_master_volume_scale(value)

func set_bgm_v(value):
	AudioUtill.set_bgm_volume_scale(value)

func set_se_v(value):
	AudioUtill.set_se_volume_scale(value)
