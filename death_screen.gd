extends Control


func _ready() -> void:
	Events.on_player_dead.connect(_on_player_dead);
	Events.on_new_game.connect(_on_new_game);

func _on_new_game() -> void:
	$AnimationPlayer.play("RESET")
	
func _on_player_dead() -> void:
	$AnimationPlayer.play("appear");
