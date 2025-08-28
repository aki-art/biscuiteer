class_name ToolBase
extends Node2D

var is_active: bool;
var data: ToolConfig;

func can_activate(data:ToolConfig) -> bool:
	return true;
	
func activate(data: ToolConfig) -> void:
	self.data = data;
	is_active = true;

func deactivate() -> void:
	is_active = false;

func on_click() -> bool:
	return false;
