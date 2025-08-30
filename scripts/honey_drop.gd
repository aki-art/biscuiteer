extends RigidBody2D

func set_wait_time(time: float) -> void:
	$ActivationTimer.wait_time = time;
	
func _on_body_entered(body: Node) -> void:
	set_deferred("freeze", true)
	body.tree_exiting.connect(_fall_again);

func _fall_again() -> void:
	set_deferred("freeze", false)
	
func _on_player_detection_area_body_entered(body: Node2D) -> void:
	var player := body as Player;
	if player:
		player.add_honey_effect();


func _on_activation_timer_timeout() -> void:
	$CollisionShape2D.disabled = false;
	$PlayerDetectionArea/CollisionShape2D.disabled = false;
