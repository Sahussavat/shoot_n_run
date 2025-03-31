extends Node2D

var coin = preload("res://nodes/hitbox_objs/coin.tscn")
@onready var floors_control = get_tree().get_first_node_in_group(GroupsName.FLOOR_CONTROL).floor_control

# Called when the node enters the scene tree for the first time.
func _ready():
	if floors_control.is_spawnable_coin:
		spawn_coins()

func spawn_coins():
	var children = get_children()
	for child in children:
		var center_len = get_collision(child).shape.size.x/2.0
		var coin_inst = coin.instantiate()
		coin_inst.position = child.position
		coin_inst.position.x = coin_inst.position.x + center_len
		coin_inst.position.y = coin_inst.position.y - 50
		add_child(coin_inst)

func get_collision(obj):
	var children = obj.get_children()
	for child in children:
		if child is CollisionShape2D:
			return child
	return null
