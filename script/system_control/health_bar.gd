extends Node

var progress_bar
var health

# Called when the node enters the scene tree for the first time.
func _init(_progress_bar, _health):
	self.progress_bar = _progress_bar
	self.health = _health
	health.change_health.connect(update_bar)
	update_bar()

func update_bar():
	progress_bar.value = progress_bar.max_value * ( health.health / float(health.max_health))


