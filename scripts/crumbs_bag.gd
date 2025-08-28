extends RigidBody2D

@export var crumb_count := 15;

func _on_pickup_area_body_entered(body: Node2D) -> void:
	if body is Player:
		(body as Player).add_crumbs(crumb_count)
	queue_free()
