extends StaticBody2D

@export var max_health = 50
var health = preload("res://script/system_control/health.gd")
var health_bar_control = preload("res://script/system_control/enemy_health_bar.gd")

# Called when the node enters the scene tree for the first time.
func _ready():
	health = health.new(max_health)
	health.add_on_death(destroy)
	health_bar_control = health_bar_control.new(self, health)
	health_bar_control.set_size_bar(100, 20)
	health_bar_control.set_position_bar(-50 \
		, position.y - get_node("CollisionShape2D").shape.size.y + 10)

func destroy():
	ScoreControl.score_delta(50)
	queue_free()
