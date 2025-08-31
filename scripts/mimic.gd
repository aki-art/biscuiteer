extends Node2D

const BEE = preload("res://scenes/bee.tscn")
var triggered := false;

func _on_player_detection_range_body_entered(body: Node2D) -> void:
	var player = body as Player;
	if player:
		$DamageParticles.emitting = true;
		$AudioStreamPlayer2D.play()
		$PlayerDetectionRange/CollisionShape2D.set_deferred("disabled", true)
		$Sprite2D.visible = false;
		$FreeTimer.start()
		triggered = true;
		var bee := BEE.instantiate() as Node2D;
		get_parent().add_child(bee);
		bee.global_position = global_position;


func _on_free_timer_timeout() -> void:
		queue_free()
