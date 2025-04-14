extends Node

var danger_arrow_img = preload("res://img/hitbox_obj_img/triangle.png")
var to_color = preload("res://shader/to_color.gdshader")
var danger_zone
var danger_arrow
var danger_zone_cooldown_bar
var danger_zone_height
var danger_zone_width = 2000
var old_pos
var parent

var tween
# Called when the node enters the scene tree for the first time.
func _init(_parent, collision):
	self.parent = _parent
	danger_zone = ColorRect.new()
	danger_zone.visible = false
	danger_zone_height = collision.shape.size.y
	danger_zone.size = Vector2(danger_zone_width, danger_zone_height)
	var _color = Color.RED
	_color.a = 0.5
	danger_zone.color = _color
	danger_zone_cooldown_bar = danger_zone.duplicate()
	danger_zone_cooldown_bar.visible = true
	danger_zone_cooldown_bar.size.y = 0.1
	old_pos = danger_zone_cooldown_bar.position
	danger_zone_cooldown_bar.position.y = danger_zone_cooldown_bar.position.y + danger_zone_height / 2.0
	add_child(danger_zone)
	danger_zone.add_child(danger_zone_cooldown_bar)
	danger_zone.z_index = -1
	danger_zone_cooldown_bar.z_index = -1
	danger_zone.pivot_offset.y = danger_zone_height / 2.0
	
	danger_arrow = TextureRect.new()
	danger_arrow.set_texture(danger_arrow_img)
	danger_arrow.size.x = danger_zone_width
	danger_arrow.size.y = danger_arrow_img.get_size().y
	danger_arrow.scale.y = danger_zone_height/danger_arrow_img.get_size().y
	danger_arrow.stretch_mode = TextureRect.STRETCH_TILE
	danger_arrow.material = ShaderMaterial.new()
	danger_arrow.material.shader = to_color
	danger_arrow.material.set_shader_parameter("color", Vector4(1, 0, 0, 0.7))
	danger_zone.add_child(danger_arrow)

func follow(target):
	danger_zone.visible = true
	var target_pos = target
	if not (target_pos is Vector2):
		target_pos = target.global_position
	if is_instance_valid(danger_zone):
		danger_zone_cooldown_bar.size.x = danger_zone.size.x
		danger_arrow.size.x = danger_zone.size.x
		danger_zone.global_position = parent.global_position
		
		var danger_zone_angle = (target_pos - parent.global_position).angle()
		danger_zone.rotation = danger_zone_angle
	

func start_cooldown(call_back):
	tween = parent.create_tween()
	var duration = 1
	danger_zone_cooldown_bar.size.y = 0.1
	danger_zone_cooldown_bar.global_position = danger_zone.global_position
	danger_zone_cooldown_bar.position.y = danger_zone_cooldown_bar.position.y + danger_zone_height / 2.0
	tween.tween_property(danger_zone_cooldown_bar, "size:y", danger_zone_height, duration)
	tween.parallel().tween_property(danger_zone_cooldown_bar, "position", old_pos, duration)
	tween.tween_callback(func():
		call_back.call()
		danger_zone.visible = false
	)

func destroy():
	if tween:
		tween.kill()
	danger_zone.visible = false
