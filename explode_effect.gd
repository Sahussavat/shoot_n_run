extends Node

var explode_shader = preload("res://shader/explode.gdshader")
var explode_tex = preload("res://wood_texture.jpg")

func explode(sprite):
	var sprite_dup
	var parent
	var sprite_temp
	if sprite is Sprite2D:
		sprite_dup = sprite.duplicate()
		sprite_temp = sprite
		parent = sprite.get_parent()
	else:
		sprite_temp = get_sprite(sprite)
		sprite_dup = sprite_temp.duplicate()
		parent = sprite
	sprite_dup.global_position = sprite_temp.global_position
	sprite_dup.rotation = parent.rotation
	sprite_dup.scale = sprite_temp.scale * parent.scale
	parent.get_parent().add_child(sprite_dup)
	sprite_dup.material = ShaderMaterial.new()
	sprite_dup.material.shader = explode_shader
	sprite_dup.material.set_shader_parameter("dissolve_texture", explode_tex)
	var tween = get_tree().create_tween()
	tween.tween_method(dissolve_fn.bind(sprite_dup), 1.0, 0.0, 1)
	tween.tween_callback(sprite_dup.queue_free)

func get_sprite(obj):
	var children = obj.get_children()
	for child in children:
		if child is Sprite2D:
			return child
	return null

func dissolve_fn(v : float, sprite_dup = null):
	if sprite_dup and is_instance_valid(sprite_dup):
			sprite_dup.material.set_shader_parameter("dissolve_value", v)
