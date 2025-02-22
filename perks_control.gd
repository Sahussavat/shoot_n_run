extends Node

var perks = {
	
}

func _ready():
	for perk_k in perks:
		var perk = load(perks[perk_k]).new()
		if perk.has_method("active_perk"):
			perk.active_perk()
