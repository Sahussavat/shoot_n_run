extends Node

var value = 0
var parent
signal value_changed

func _init(_parent):
	self.parent = _parent 

func delta_value(_value):
	set_value(value + _value)

func set_value(_value):
	self.value = _value
	value_changed.emit(value)
