extends Area2D

@onready var extend_timer: Timer = $ExtendTimer
@onready var retract_timer: Timer = $RetractTimer
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var extended_time: float;
@export var retracted_time: float;
@export var timer_offset: float;
@export var is_active: bool;
@export var is_extended : bool;

func _ready() -> void:
	extend_timer.wait_time = extended_time;
	retract_timer.wait_time = retracted_time;
	if timer_offset > 0:
		$SpawnWaitTime.wait_time = timer_offset;
		$SpawnWaitTime.start();
	
	else:
		start_cycle();
		
		
	if !is_extended:
		animation_player.play("idle_retracted")
		

func set_active(active:bool) -> void:
	if is_active == active:
		return;
		
func _on_retract_timer_timeout() -> void:
	animation_player.play("retract")
	extend_timer.start()

func _on_spawn_wait_time_timeout() -> void:
	if is_extended:
		retract_timer.start();
	else:
		extend_timer.start();

func start_cycle() -> void:
	animation_player.play("extend")
	retract_timer.start()
	
func _on_extend_timer_timeout() -> void:
	start_cycle();
