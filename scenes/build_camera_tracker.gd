extends Marker2D

@export var speed := 200.0;
@export var anchor := Node2D;
@export var leash_length := 400.0;
@export var is_active := false;

func _physics_process(delta: float) -> void:
	
	if !is_active:
		return;
		
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down");
	
	var next_pos := global_position + (direction * speed * delta);
	if anchor.global_position.distance_to(next_pos) < leash_length:
		position = next_pos;
	
