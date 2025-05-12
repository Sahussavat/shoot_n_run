extends Area2D

@export var damage = 5
signal entity_death

# Called when the node enters the scene tree for the first time.
func _ready():
	area_entered.connect(_on_area_entered)

func _on_area_entered(area):
	if "health" in area.get_parent() and area.get_parent().health:
		var health = area.get_parent().health
		health.do_damage(damage, get_parent())
		if health.is_dead():
			entity_death.emit(area.get_parent())
