class_name CrumbWallet
extends Node

@export var crumbs: int;

func set_count(count: int) -> void:
	crumbs = count;
	crumbs = max(0, crumbs);
	Events.on_crumbs_changed.emit(crumbs);
	
func add(count: int) -> void:
	set_count(crumbs + count);

func can_afford(cost: int) -> bool: return crumbs >= cost;

func remove(count: int) -> void:
	set_count(crumbs - count);
