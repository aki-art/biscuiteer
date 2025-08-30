extends Node2D

@export var drop_timer: float = 2.0;
@export var drop_activation: float = 0.15;
@export var drop_prefab: PackedScene;

@onready var timer: Timer = $Timer


func _ready() -> void:
	timer.wait_time = drop_timer;
	


func _on_timer_timeout() -> void:
	var drop := drop_prefab.instantiate() as Node2D;
	get_parent().add_child(drop);
	drop.global_position = global_position;
	
	drop.set_wait_time(drop_activation);
	
