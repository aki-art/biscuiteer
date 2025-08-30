class_name  ToolButton
extends Button

@export var tool:String;
@export var data: ToolConfig

func _on_pressed() -> void:
	Global.game.activate_tool(tool, data);
