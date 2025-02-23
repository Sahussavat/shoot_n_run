extends Node

var groups = {}

func add_entity_to_group(group_name, entity):
	if not groups.has(group_name):
		groups[group_name] = [entity]
	else:
		groups[group_name].append(entity)

func remove_entity_from_group(group_name, entity):
	if groups.has(group_name):
		for i in range(0, groups[group_name].size()):
			if groups[group_name][i] == entity:
				groups[group_name].remove_at(i)
				break;
