extends TextureRect

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	Events.on_honeyed.connect(_on_honeyed);
	Events.on_honey_dried.connect(_on_honey_dried);

func _on_honeyed():
	animation_player.play("appear");

func _on_honey_dried():
	animation_player.play_backwards("appear");
