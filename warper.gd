class_name Warper
extends Area2D

@export var destination: String;

func _on_body_entered(body: Node2D) -> void:
	if body is Player && destination:
		SceneFlow.load_level(destination);
	
