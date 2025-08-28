extends RigidBody2D

func _on_pickup_area_body_entered(body: Node2D) -> void:
	if body is Player:
		(body as Player).health.heal(1);
		
	queue_free()
