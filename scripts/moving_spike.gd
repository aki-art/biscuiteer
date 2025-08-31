extends Area2D

@onready var extend_timer: Timer = $ExtendTimer
@onready var retract_timer: Timer = $RetractTimer
@onready var spawn_wait_timer: Timer = $SpawnWaitTime
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
		spawn_wait_timer.wait_time = timer_offset;
		spawn_wait_timer.start();
	
	else:
		start_cycle();
		
		
	if !is_extended:
		animation_player.play("idle_retracted")
	
	Events.on_game_mode_changed.connect(_on_game_mode_changed);
		
func _on_game_mode_changed(mode: StringName):
	var is_paused := mode == "building";
	extend_timer.paused = is_paused;
	retract_timer.paused = is_paused;
	spawn_wait_timer.paused = is_paused;
	
	if is_paused:
		animation_player.pause()
	else:
		if animation_player.assigned_animation:
			animation_player.play(animation_player.assigned_animation)
	

func extend() -> void:
	animation_player.play("extend")
	extend_timer.start()
	is_extended = true;

func retract() -> void:
	animation_player.play("retract")
	retract_timer.start()
	is_extended = false;
	
func set_active(active:bool) -> void:
	if is_active == active:
		return;
		
func _on_retract_timer_timeout() -> void:
	extend()

func _on_spawn_wait_time_timeout() -> void:
	start_cycle()

func start_cycle() -> void:
	extend()
	
func _on_extend_timer_timeout() -> void:
	retract()
