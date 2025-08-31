extends TextureRect

#@onready var animation_player: AnimationPlayer = $AnimationPlayer

var honey_timer: float;

var elapsed : float;
const DURATION := 2.0;
var current_alpha := 0.0;
var is_honeyed := false;

@export var fade_speed := 1.0;

func _ready() -> void:
	Events.on_honeyed.connect(_on_honeyed);
	Events.on_honey_dried.connect(_on_honey_dried);

func _process(delta: float) -> void:
	var t := elapsed / DURATION;
	var target := 1.0 if is_honeyed else 0.0;
	
	modulate.a = move_toward(modulate.a, target, fade_speed * delta);
	
func _on_honeyed():
	is_honeyed = true;
	elapsed = 0;
	
#	animation_player.play("appear");

func _on_honey_dried():
	is_honeyed = false;
