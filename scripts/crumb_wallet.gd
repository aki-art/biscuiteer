class_name CrumbWallet
extends Node

@export var crumbs: int;

var _previous_crumbs : int;

func _ready() -> void:
	Events.on_level_reset.connect(_on_level_reset);
	Events.on_level_loaded.connect(_on_level_loaded);
	set_count(0)
	
func _on_level_reset() -> void:
	call_deferred("set_count", _previous_crumbs);

func _on_level_loaded(_level: Level, is_reset: bool) -> void:
	if !is_reset:
		_previous_crumbs = crumbs;
	
func set_count(count: int) -> void:
	crumbs = count;
	crumbs = max(0, crumbs);
	Events.on_crumbs_changed.emit(crumbs);
	
func add(count: int) -> void:
	if Global.game._is_resetting_level:
		return;
		
	set_count(crumbs + count);

func can_afford(cost: int) -> bool: return crumbs >= cost;

func remove(count: int) -> void:
	set_count(crumbs - count);
