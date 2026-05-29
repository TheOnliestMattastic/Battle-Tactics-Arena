class_name APComponent
extends Node

# Configs
const max_ap: int = 5
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
func gain_ap(amt: int) -> int:
	current_ap = min(current_ap + amt, max_ap)
	return current_ap
