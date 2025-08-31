class_name Health
extends Node

signal on_health_changed(health_delta: int);
signal on_shield_changed(shield_delta: int);
signal on_death();
signal on_hurt(amount: float, fatal: bool, source: StringName, position: Vector2);

@export var max_hp: int;
@export var armor : int;
@export var current_shield: int;
@export var current_hp: int;
@export var is_dead : bool;
@export var iframes_timer: Timer;
@export var invulnerable: bool;

var _previous_hp : int;

func _ready() -> void:
	Events.on_level_reset.connect(_on_level_reset);
	Events.on_level_loaded.connect(_on_level_loaded);
	
func _on_level_reset() -> void:
	call_deferred("set_hp", _previous_hp);

func _on_level_loaded(_level: Level, is_reset: bool) -> void:
	if !is_reset:
		_previous_hp = current_hp;
	
	
func is_full_health() -> bool: 
	return current_hp >= max_hp;

func total_health() -> int: 
	return current_hp + current_shield;

func heal(hp: int) -> void:
	if is_full_health():
		return;

	add_hp(hp);
	
func add_hp(hp:int) -> int: 
	return set_hp(current_hp + hp);

func set_hp(hp:int, trigger_event:bool = true) -> int:
	var previpus_hp = current_hp;

	current_hp = hp;
	current_hp = min(current_hp, max_hp);

	if (trigger_event):
		on_health_changed.emit(previpus_hp - current_hp);

		if (current_hp <= 0 && current_shield <= 0):
			is_dead = true;
			on_death.emit()

	Events.on_player_hp_changed.emit(total_health())
	return current_hp - previpus_hp;

func damage(amount: int, source: StringName, position:Vector2) -> void:
	
	if invulnerable:
		return;
		
	if iframes_timer && !iframes_timer.is_stopped():
		return;
		
	var damage_reduction = (int)(amount * armor);
	amount -= damage_reduction;

	if amount == 0:
		return;

	if current_shield > 0:
		var shield_damage = min(amount, current_shield);
		current_shield -= shield_damage;
		amount -= shield_damage;

		on_shield_changed.emit(-shield_damage);

	add_hp(-amount);
	on_hurt.emit(amount, total_health() <= 0, source, position);
	
	if iframes_timer:
		iframes_timer.start()

func set_max_hp(health: int, trigger_event:bool = true) -> void:
	max_hp = health;
	set_hp(max_hp, trigger_event);
