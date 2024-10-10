extends StaticBody2D

var value = 10

# Called when the node enters the scene tree for the first time.
func _ready():
	var hitbox = get_area2d()
	hitbox.body_entered.connect(hit_player)

func hit_player(body):
	if body.is_in_group(GroupsName.PLAYER):
		var player = body
		player.coin_c_player.delta_value(value)
		destroy()

func get_area2d():
	var children = get_children()
	for child in children:
		if child is Area2D:
			return child
	return null

func destroy():
	queue_free()
