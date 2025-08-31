class_name ToolBase
extends Node2D

var is_active: bool;
var data: ToolConfig;
@export var cursor: Resource;
@export var offset: Vector2 = Vector2.ZERO;
const CURSOR_DEFAULT = preload("res://assets/cursors/cursor_default.png")
const DEFAULT_OFFSET = Vector2(10.5, 4.25);
func can_activate(data:ToolConfig) -> bool:
	return Global.game.player.state != "dead";
	
func activate(data: ToolConfig) -> void:
	self.data = data;
	is_active = true;
	if(cursor):
		Input.set_custom_mouse_cursor(cursor, Input.CursorShape.CURSOR_ARROW, offset)

func deactivate() -> void:
	is_active = false;
	if(cursor):
		Input.set_custom_mouse_cursor(CURSOR_DEFAULT, Input.CursorShape.CURSOR_ARROW, DEFAULT_OFFSET)

func on_click() -> bool:
	return false;
