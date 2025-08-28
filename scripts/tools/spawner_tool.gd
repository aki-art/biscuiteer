class_name SpawnerTool
extends ToolBase

var target:Node2D;
var was_target_sandbox_spawned:bool;
var _is_dragging:bool = false;
var _target_dropped:bool = false;

func activate(data: ToolConfig) -> void:
	super(data);
	
	_target_dropped = false;
	
	if(data != null && data is SpawnConfig):
		var config = data as SpawnConfig;
		was_target_sandbox_spawned = true;
		target = config.scene.instantiate();
		get_parent().add_child(target);
		
		_is_dragging = true;

func deactivate() -> void:
	super();
	
	if(!_target_dropped && was_target_sandbox_spawned):
		if(target != null):
			target.queue_free();
	
	was_target_sandbox_spawned = false;
	target = null;
	
func on_click() -> bool:
	if(!is_active):
		return false;
	
	if(target != null && target is Platform):
		# check if placeable
		if true:
			target.activate();
		else:
			# TODO: feedback
			deactivate();
			
		_target_dropped = true;
	
	deactivate();
	
	return true;
	
func _process(delta: float) -> void:
	#if(!Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)):
	#	deactivate();
		
	if(target != null):
		target.global_position = get_global_mouse_position();
