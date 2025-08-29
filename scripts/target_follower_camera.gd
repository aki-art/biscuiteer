class_name TargetFollowerCamera
extends Camera2D

@export var target:Node2D;
@export var speed:float = 400.0;
@export var _zoom:float = 1.0;
@export var zoom_duration:float = 0.2
@export var zoom_factor:float = 0.1
@onready var tween:Tween;
@export var allow_user_zoom := false;

func target_zoom_level(zoom: float) -> void:
	_zoom_level = zoom;

var _zoom_level : float :
	get:
		return _zoom
	set(value):
		tween = get_tree().create_tween();
		tween.tween_property(
			self,
			"zoom",
			Vector2(value, value),
			zoom_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EaseType.EASE_OUT);
			
		_zoom = value;
		return;
		
func _process(delta: float) -> void:
	var target_position = Vector2(target.position.x, target.position.y);
	var unscaled_delta:= delta * (1.0 / Engine.time_scale);
	
	position = lerp(position, target_position, speed* delta); # * unscaled_delta);
	
func _unhandled_input(event):
	if allow_user_zoom:
		if event.is_action_pressed("zoom_in"):
			_zoom_level += zoom_factor
		if event.is_action_pressed("zoom_out"):
			_zoom_level -= zoom_factor
