extends StaticBody2D

const MAX_SPEED = 35

var raycast = RayCast2D.new()
var target_pos
var direction
var destory_timer
@onready var hitbox = get_hitbox()
# Called when the node enters the scene tree for the first time.
func _ready():
	destory_timer = Timer.new()
	destory_timer.wait_time = 1
	destory_timer.one_shot = true
	destory_timer.autostart = true
	destory_timer.timeout.connect(destroy)
	add_child(destory_timer)
	hitbox.body_entered.connect(destroy_on_wall)
	
	raycast.set_collision_mask_value(3, true)
	add_child(raycast)

func get_hitbox():
	var children = get_children()
	for child in children:
		if child is Area2D:
			return child
	return null

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if target_pos:
		if not direction:
			rotate_by_target()
			direction = (target_pos - position).normalized()
		var pos_move = position + (direction * MAX_SPEED)
		destroy_on_wall_raycast_at(pos_move)
		position = pos_move

func destroy_on_wall(body):
	if body.get_collision_layer() == 4:
		destroy()

func destroy_on_wall_raycast_at(pos):
	raycast.target_position = to_local(pos)
	if raycast.get_collider():
			destroy()

func rotate_by_target():
	var degrees = global_position.direction_to(target_pos).angle()
	rotation = degrees

func destroy():
	self.queue_free()
