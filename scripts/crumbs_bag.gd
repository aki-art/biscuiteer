extends RigidBody2D

@export var crumb_count := 15;
var consumed := false;


func _on_pickup_area_body_entered(body: Node2D) -> void:
	if consumed:
		return;
		
	if body is Player:
		(body as Player).add_crumbs(crumb_count)
		
		$DamageParticles.emitting = true;
		$AudioStreamPlayer2D.play()
		$CollisionShape2D.set_deferred("disabled", true)
		$Sprite2D.visible = false;
		$FreeTimer.start()
		consumed = true;
		

func _on_free_timer_timeout() -> void:
	queue_free()
