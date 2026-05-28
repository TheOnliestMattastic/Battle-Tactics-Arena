class_name APComponent
extends Node

# Configs
var current_ap: int = 3

# Spend AP
func spend_ap(cost: int):
	if cost > current_ap:
		print("Not enough AP!")
		return
	else:
		current_ap = current_ap - cost 
		return current_ap

# Gain AP
func gain_ap(amt: int):
	current_ap = min(current_ap + amt, GameMaster.MAX_AP)
	return current_ap
