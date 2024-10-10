extends ProgressBar

var health_bar = preload("res://health_bar.gd")
@onready var player = get_parent().get_parent().get_node("tako")
@onready var player_health = player.health.health

# Called when the node enters the scene tree for the first time.
func _ready():
	health_bar = health_bar.new(self, player_health)
