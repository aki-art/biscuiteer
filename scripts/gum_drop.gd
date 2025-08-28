extends StaticBody2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func impact(node: Node2D) -> void:
	if node is Player:
		var player:Player = node;
		player.force = -(player.previous_velocity * 2.0);
