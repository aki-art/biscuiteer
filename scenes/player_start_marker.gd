@tool
extends Marker2D

func _ready() -> void:
	if !Engine.is_editor_hint():
		$Sprite2D.visible = false;
