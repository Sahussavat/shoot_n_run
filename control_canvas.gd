extends CanvasLayer

@onready var black_fade = get_node("black_fade")
# Called when the node enters the scene tree for the first time.

func do_fade_black(call_back):
	fade_in(call_back)

func fade_in(call_back):
	var tween = create_tween()
	tween.tween_property(black_fade, "color", Color.BLACK, 0.25)
	tween.tween_callback(func():
		call_back.call()
		fade_out()
		)

func fade_out():
	var tween = create_tween()
	var _color = Color.BLACK
	_color.a = 0
	tween.tween_property(black_fade, "color", _color, 0.7)
	
