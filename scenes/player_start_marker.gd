@tool
extends Marker2D

@export var facing_left: bool;

func _ready() -> void:
	if !Engine.is_editor_hint():
		$Sprite2D.visible = false;
		
