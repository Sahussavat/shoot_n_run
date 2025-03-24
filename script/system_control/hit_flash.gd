extends Node

var parent
var sprite
var mat = ShaderMaterial.new()
var is_hit_flashing = false

# Called when the node enters the scene tree for the first time.
func _init(_parent):
	parent = _parent
	sprite = get_sprite(parent)
	mat.shader = preload("res://shader/to_color.gdshader")
	mat.set_shader_parameter("color", Vector4(1, 1, 1, 1))

func do_hit_flash():
	if not is_hit_flashing and not parent.health.is_died:
		is_hit_flashing = true
		parent.get_tree().create_timer(0, false).timeout.connect(hit_flash)

func hit_flash():
	if is_instance_valid(sprite):
		sprite.material = mat
		await parent.get_tree().create_timer(0.05, false).timeout
	if is_instance_valid(sprite):
		sprite.material = null
	is_hit_flashing = false

func get_sprite(obj):
	var children = obj.get_children()
	for child in children:
		if child is Sprite2D:
			return child
	return null
