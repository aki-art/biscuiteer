class_name Game
extends Node2D

@onready var tools:Dictionary[StringName,ToolBase] = {}
@export var _mode : StringName = "platforming";
@onready var player: Player = $Player
@export var start_level: String;
@onready var player_follow_camera: TargetFollowerCamera = $PlayerFollowCamera
@onready var build_camera_tracker: Marker2D = $BuildCameraTracker

@export var last_building_tool : StringName;
@export var last_tool_data : ToolConfig;


var _current_level: Level;

var active_tool:ToolBase;

func set_mode(mode: StringName) -> void:
	if _mode == mode:
		return;
	
	_mode = mode;
	Events.on_game_mode_changed.emit(mode);
	
	# TODO:pause
	# Engine.time_scale = 1.0 if _mode != "building" else 0.03;
	
	if mode == "platforming":
		build_camera_tracker.is_active = false;
		player_follow_camera.target = player;
		player_follow_camera.allow_user_zoom = false;
		player_follow_camera.target_zoom_level(0.85);
	else:
		build_camera_tracker.global_position = player.global_position;
		build_camera_tracker.is_active = true;
		player_follow_camera.target = build_camera_tracker;
		player_follow_camera.allow_user_zoom = true;
		player_follow_camera.target_zoom_level(0.7);
	
func _ready() -> void:
	Global.game = self;
	var toolsNode = $Tools
	for node:Node in toolsNode.get_children(false):
		tools[node.name] = node;
	
	SceneFlow.load_level(start_level);
	
	
func set_current_level() -> void:
	_current_level = get_tree().get_first_node_in_group("level")
	_current_level.call_deferred("start_level", player);
	
func get_current_level() -> Level:
	if !_current_level:
		set_current_level();
	
	return _current_level;
	
func _enter_tree() -> void:
	pass;
	
func activate_tool(tool_id: StringName, data: ToolConfig) -> bool:
	var tool:ToolBase = tools.get(tool_id);
	if(tool == null):
		return false;
	
	if !tool.can_activate(data):
		return false;
		
	if(active_tool != null):
		active_tool.deactivate();
		
	tool.activate(data);
	active_tool = tool;
	
	return true;
	
func _input(event: InputEvent) -> void:
	if(Input.is_action_just_pressed("click")):
		if(active_tool != null && active_tool.on_click()):
			get_viewport().set_input_as_handled();
	
	elif(Input.is_action_just_pressed("cancel")):
		if(active_tool != null):
			active_tool.deactivate();
			if _mode == "building":
				Events.on_toggle_build_mode.emit(false);
				Global.game.set_mode("platforming")
			get_viewport().set_input_as_handled();
		
	elif(Input.is_action_just_pressed("quick_build")):
		if _mode == "building":
			Events.on_toggle_build_mode.emit(false);
			Global.game.set_mode("platforming")
			if active_tool:
				active_tool.deactivate()
		elif _mode == "platforming":
			activate_tool(last_building_tool, last_tool_data);
			
	
	elif(Input.is_action_just_pressed("full_screen_toggle")):
		var currentMode = DisplayServer.window_get_mode();
		var targetMode = DisplayServer.WINDOW_MODE_FULLSCREEN if currentMode == DisplayServer.WINDOW_MODE_WINDOWED else DisplayServer.WINDOW_MODE_WINDOWED; 
		DisplayServer.window_set_mode(targetMode);
	
	elif(Input.is_action_just_pressed("reset")):
		player.reset_position();
		
func _process(delta: float) -> void:
	pass
