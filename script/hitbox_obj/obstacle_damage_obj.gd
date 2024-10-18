extends Area2D

@export var damage = 5

# Called when the node enters the scene tree for the first time.
func _ready():
	area_entered.connect(_on_area_entered)

func _on_area_entered(area):
	if "health" in area.get_parent() and area.get_parent().health:
		var health = area.get_parent().health
		health.do_damage(damage)
