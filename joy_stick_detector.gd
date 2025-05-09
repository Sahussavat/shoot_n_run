extends Node

func is_joy_connected():
	return Input.get_connected_joypads().size() > 0
