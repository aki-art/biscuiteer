class_name  ToolButton
extends Button

@export var tool:String;
@export var data: ToolConfig

const DEFAULT := Color.WHITE;
const HIGHLIGHT := Color(1.15, 1.15, 1.15, 1.0);

func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered);
	mouse_exited.connect(_on_mouse_exited);

func _on_mouse_entered() -> void:
	position.y -= 10.0;
	modulate = HIGHLIGHT;
	$AudioStreamPlayer.play();
	
func _on_mouse_exited() -> void:
	position.y += 10.0;
	modulate = DEFAULT;
	
func _on_pressed() -> void:
	Global.game.activate_tool(tool, data);
