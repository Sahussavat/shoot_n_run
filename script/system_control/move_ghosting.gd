extends Node

var parent

# Called when the node enters the scene tree for the first time.
func _init(_parent):
	parent = _parent

func create():
	var original_sprite = get_sprite()
	if original_sprite:
		var sprite_ghost = Sprite2D.new()
		sprite_ghost.texture = original_sprite.texture
		sprite_ghost.hframes = original_sprite.hframes
		sprite_ghost.vframes = original_sprite.vframes
		sprite_ghost.frame = original_sprite.frame
		sprite_ghost.scale = original_sprite.scale
		parent.get_parent().add_child(sprite_ghost)
		sprite_ghost.global_position = parent.global_position
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
