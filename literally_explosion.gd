extends Node
var explode1 = preload("res://img/explosion/Half Sized/1.png")
var explode2 = preload("res://img/explosion/Half Sized/2.png")
var explode3 = preload("res://img/explosion/Half Sized/3.png")
var explode4 = preload("res://img/explosion/Half Sized/4.png")
var explode_node = preload("res://nodes/enemies/explode.tscn")
var to_color = preload("res://shader/to_color.gdshader")

func explode(sprite, callback = null):
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
	var ex_n = explode_node.instantiate()
	sprite_dup.add_child(ex_n)
	sprite_dup.material = ShaderMaterial.new()
	sprite_dup.material.shader = to_color
	sprite_dup.material.set_shader_parameter("color", Color(1,1,1,1))
	await get_tree().create_timer(0.5).timeout
	sprite_dup.material = null
	var duration_time = 4
	var tween = get_tree().create_tween()
	#tween.tween_property(sprite_dup, "position:y", sprite_dup.position.y - 100, duration_time)
	#tween.parallel()
	tween.tween_property(sprite_dup, "self_modulate", Color(1,1,1,0), duration_time)
	tween.parallel()
	tween.tween_method(do_explosion.bind(ex_n), 1, 4, duration_time)
	tween.tween_callback(func():
		if callback:
			callback.call()
		if is_instance_valid(sprite_dup):
			sprite_dup.queue_free()
		)

func do_explosion(_type, _explode_node):
	var t = [explode1, explode2, explode3, explode4]
	t.shuffle()
	var ani : AnimationPlayer = _explode_node.get_node("AnimationPlayer")
	var sprite : Sprite2D = _explode_node.get_node("Sprite2D")
	sprite.texture = t[randi_range(0, t.size() - 1)]
	ani.play()
	

func get_sprite(obj):
	var children = obj.get_children()
	for child in children:
		if child is Sprite2D:
			return child
	return null
