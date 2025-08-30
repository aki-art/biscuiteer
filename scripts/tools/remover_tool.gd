class_name RemoverTool
extends ToolBase

func can_activate(data:ToolConfig) -> bool:
	var player := Global.game.player;
	if !player:
		return false;
		
	return player.is_on_floor();
	
func activate(data: ToolConfig) -> void:
	super(data);
	Global.game.set_mode("building")

func deactivate() -> void:
	super();
	
func on_click() -> bool:
	
	if Global.game.remove_targets.size() > 0:
		Global.game.remove_targets[-1].destroy();
		
	return true;

func _process(delta: float) -> void:
	pass
