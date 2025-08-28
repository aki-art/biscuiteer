class_name PlatformSpawnerTool
extends ToolBase

var target:Platform;
var was_target_sandbox_spawned:bool;
var _is_dragging:bool = false;
var _target_dropped:bool = false;
var _start_location:Vector2;
var _has_start_location := false;

func can_activate(data:ToolConfig) -> bool:
	var player := Global.game.player;
	if !player:
		return false;
		
	return player.is_on_floor();

func activate(data: ToolConfig) -> void:
	super(data);
	
	_target_dropped = false;
	
	if(data != null && data is SpawnConfig):
		var config = data as SpawnConfig;
		was_target_sandbox_spawned = true;
		target = config.scene.instantiate();
		Global.game.get_current_level().add_child(target);
		
		target.set_ends(get_global_mouse_position(), get_global_mouse_position(), false, false)
		
		Events.on_toggle_build_mode.emit(true);
		Global.game.set_mode("building")
		
		_is_dragging = true;

func deactivate() -> void:
	super();
	
	if(!_target_dropped && was_target_sandbox_spawned):
		if(target != null):
			target.queue_free();
	
	was_target_sandbox_spawned = false;
	target = null;
	_has_start_location = false;
	
		
	
func on_click() -> bool:
	if(!is_active):
		return false;
	
	var finished := false;
	
	if(target != null && target is Platform):
		if true: # check for valid placement
			# on second click place
			if _has_start_location:
				var wallet := Global.game.player.crumb_wallet;
				if wallet && wallet.can_afford(target.cost):
					wallet.remove(target.cost);
					
				target.activate(true);
				target.set_ends(_start_location, get_global_mouse_position(), true, true)
				finished = true;
			else:
				_start_location = get_global_mouse_position();
				_has_start_location = true
		else:
			# TODO: feedback
			deactivate();
			
		_target_dropped = true;
	
	if finished:
			
		deactivate();
		activate(data);
	
	return true;
	
func _process(delta: float) -> void:
	#if(!Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)):
	#	deactivate();
	
	if(target != null):
		if _has_start_location:
			target.set_ends(_start_location, get_global_mouse_position(), false, true)
		else:
			target.global_position = get_global_mouse_position();
