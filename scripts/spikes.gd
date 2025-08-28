extends Area2D

@onready var hazard: Hazard = $Hazard

func _on_body_entered(body: Node2D) -> void:
	hazard.on_touched.emit(body);
