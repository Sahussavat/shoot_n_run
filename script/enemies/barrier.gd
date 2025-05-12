extends Sprite2D

var parent
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func init_barrier(_parent):
	parent = _parent
	var health = parent.health
	health.add_hit_condition(func(doer):
		return BulletType.is_can_hit(parent, doer)
		)
	var parent_sprite = get_sprite(parent)
	scale = parent_sprite.scale
	texture = parent_sprite.texture
	frame_coords = parent_sprite.frame_coords
	vframes = parent_sprite.vframes
	hframes = parent_sprite.hframes
	parent_sprite.frame_changed.connect(func():
		frame = parent_sprite.frame
		)

func start_barrier(type):
	remove_barrier()
	parent.add_to_group(type)
	material = ShaderMaterial.new()
	material.shader = preload("res://shader/outline.gdshader")
	material.set_shader_parameter("clr", BulletType.get_bullet_type_color(type))

func remove_barrier():
	BulletType.remove_to_all_type(parent)
	if material:
		material = null

func start_random_barrier():
	var type = BulletType.type.duplicate()
	const NONE = 'none'
	type.push_front(NONE)
	var chosen_type = type[randi_range(0, type.size() - 1)]
	if chosen_type != NONE:
		start_barrier(chosen_type)
	else:
		remove_barrier()

func get_sprite(_parent):
	var children = _parent.get_children()
	for child in children:
		if child is Sprite2D and child.name != "outline":
			return child
	return null
