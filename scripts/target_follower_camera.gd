class_name TargetFollowerCamera
extends Camera2D

@export var target:Node2D;
@export var speed:float = 400.0;
@export var _zoom:float = 1.0;
@export var zoom_duration:float = 0.2
@export var zoom_factor:float = 0.1
@onready var tween:Tween;
@export var allow_user_zoom := false;
@export var shake_curve: Curve;
@export var shake_duration := 0.3;
@export var noise: FastNoiseLite;

var shake_elapsed := 0.0;
var is_shaking := false;
var shake_power := 1.0;

func target_zoom_level(zoom: float) -> void:
	_zoom_level = zoom;

func _ready() -> void:
	Events.on_player_hurt.connect(_on_player_hurt);

func _on_player_hurt(amage: int, fatal:bool, source: StringName):
	shake(50.0);
	
func shake(power: float = 1.0) -> void:
	shake_elapsed = 0;
	is_shaking = true;
	shake_power = power;
	noise.seed = randi()
	
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
	
	if is_shaking:
	
		var t := shake_curve.sample(shake_elapsed);
		shake_elapsed += delta;
		
		if shake_elapsed > shake_duration:
			is_shaking = false;
			
		var target_offset = Vector2(noise.get_noise_2d(0, shake_elapsed), noise.get_noise_2d(shake_elapsed, 0)) * 300;
		offset = lerp(offset, target_offset, 90.0 * t * delta);
	else:
		offset = lerp(offset, Vector2.ZERO, delta);
		
	var unscaled_delta = 0.02 if Engine.time_scale <= 0 else delta * (1.0 / Engine.time_scale);
	position = lerp(position, target_position, speed * unscaled_delta); # * unscaled_delta);
	
	
func _unhandled_input(event):
	if allow_user_zoom:
		if event.is_action_pressed("zoom_in"):
			_zoom_level += zoom_factor
		if event.is_action_pressed("zoom_out"):
			_zoom_level -= zoom_factor
