@tool
class_name HazardRespawnMarker
extends Area2D

@export var facing_left: bool;

func _ready() -> void:
	if !Engine.is_editor_hint():
		$Sprite2D.visible = false;
		
func _on_body_entered(body: Node2D) -> void:
	var player := body as Player;
	if !player:
		return;
		
	player.last_respawn_point = self;
