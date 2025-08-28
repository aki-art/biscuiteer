extends Area2D

@export var destination: String;

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		SceneFlow.load_level(destination);
