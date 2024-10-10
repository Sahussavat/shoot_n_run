extends HBoxContainer


@onready var coin_value = $coin_value
@onready var player = get_tree().get_first_node_in_group(GroupsName.PLAYER)

func _ready():
	coin_value.text = str(0)
	var coin_control = player.coin_c_player
	coin_control.value_changed.connect(set_value)

func set_value(value):
	coin_value.text = str(value)

