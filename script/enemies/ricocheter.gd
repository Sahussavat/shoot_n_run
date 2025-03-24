extends CharacterBody2D

var ricochet = preload("res://script/enemies/richochet.gd")

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group(GroupsName.ENEMIES)
	ricochet = ricochet.new(self, 10)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	global_position = ricochet.move(_delta)
