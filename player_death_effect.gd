extends Node

var coin_pic = preload("res://img/hitbox_obj_img/coin.png")

func do_game_over_effect(parent, pos, call_back):
	var tween = create_tween()
	var radius = 500
	for i in range(0, 360, 40):
		var c = Sprite2D.new()
		c.texture = coin_pic
		c.global_position = pos
		c.z_index = 999
		parent.get_parent().add_child(c)
		var x = pos.x + cos(deg_to_rad(i) * PI * 2) * radius;
		var y = pos.y + sin(deg_to_rad(i) * PI * 2) * radius;
		tween.parallel()
		tween.tween_method(move_coin.bind(c), pos, Vector2(x,y), 1.5)
	tween.tween_callback(call_back)

func move_coin(pos, coin):
	coin.global_position = pos
	
