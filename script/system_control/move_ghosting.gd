extends Node

var parent

# Called when the node enters the scene tree for the first time.
func _init(_parent):
	parent = _parent

func create():
	var original_sprite = get_sprite()
	if original_sprite:
		var sprite_ghost = Sprite2D.new()
		sprite_ghost = original_sprite.duplicate()
		sprite_ghost.visible = true
		sprite_ghost.global_position = original_sprite.global_position
		parent.get_parent().add_child(sprite_ghost)
		var tween_fade = parent.get_tree().create_tween()
 
		tween_fade.tween_property(sprite_ghost, "self_modulate",Color(1, 1, 1, 0), 0.25 )
		tween_fade.tween_callback(func():
			if sprite_ghost:
				sprite_ghost.queue_free()
			)

func get_sprite():
	var children = parent.get_children()
	for child in children:
		if child is Sprite2D:
			return child
	return null
