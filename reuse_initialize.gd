extends Node

var used_entities = {}

func initialize(_name, entity):
	if used_entities.has(_name):
		if used_entities[_name].size() > 0:
			var reuse_entity = used_entities[_name].pop_back()
			reuse_entity._re_ready()
			reuse_entity.set_deferred("process_mode", Node.PROCESS_MODE_INHERIT)
			reuse_entity.visible = true
			return reuse_entity
	var en = entity.instantiate()
	return en

func to_reuse(_name, entity):
	entity.process_mode = Node.PROCESS_MODE_DISABLED
	entity.visible = false
	if not used_entities.has(_name):
		used_entities[_name] = []
	used_entities[_name].push_front(entity)

func reset_used_entities():
	used_entities.clear()
