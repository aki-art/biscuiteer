class_name Game
extends Node2D

@onready var tools:Dictionary[StringName,ToolBase] = {}
@export var _mode : StringName = "platforming";
@onready var player: Player = $Player
@export var start_level: String;
@onready var player_follow_camera: TargetFollowerCamera = $PlayerFollowCamera
@onready var build_camera_tracker: Marker2D = $BuildCameraTracker
@onready var pause_menu: Control = $CanvasLayer/PauseMenu

@export var last_building_tool : StringName;
@export var last_tool_data : ToolConfig;
@export var time_slow := 0.025;
@export var remove_targets : Array[Node2D] = [];

const PLATFORM_MATERIAL = preload("res://assets/particle_materials/platform.tres")

var _current_level: Level;
var _is_resetting_level: bool;

var active_tool:ToolBase;
var loaded: bool;
var is_paused : bool = false;

func set_mode(mode: StringName) -> void:
	if _mode == mode:
		return;
	
	_mode = mode;
	Events.on_game_mode_changed.emit(mode);
	
	# Engine.time_scale = 1.0 if _mode != "building" else time_slow;
	
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

func reset_level() -> void:
	Events.on_level_reset.emit()
	$ResetTimer.start();
	
func _ready() -> void:
	Global.game = self;
	var toolsNode = $Tools
	for node:Node in toolsNode.get_children(false):
		tools[node.name] = node;
	
	var particles_instance = GPUParticles2D.new()
	particles_instance.set_process_material(PLATFORM_MATERIAL)
	particles_instance.set_one_shot(true)
	particles_instance.set_emitting(true)
	self.add_child(particles_instance)
	
	SceneFlow.load_level(start_level);
	
	Events.on_player_dead.connect(_on_player_dead);
	
func _on_player_dead():
	if(active_tool != null):
		active_tool.deactivate();
	
func set_current_level() -> void:
	_current_level = get_tree().get_first_node_in_group("level")
	_current_level.call_deferred("start_level", player);
	remove_targets.clear();
	
	Events.on_level_loaded.emit(_current_level, _is_resetting_level)
	_is_resetting_level = false;
	
func get_current_level() -> Level:
	if !_current_level:
		_current_level = get_tree().get_first_node_in_group("level")
	
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

var frames : int;

func _physics_process(delta: float) -> void:
	if(frames > 0):
		set_physics_process(false);
	
	frames += 1;
	
func _input(event: InputEvent) -> void:
	if(Input.is_action_just_pressed("click")):
		if(active_tool != null && active_tool.on_click()):
			get_viewport().set_input_as_handled();
	
	elif(Input.is_action_just_pressed("cancel")):
		if(active_tool != null):
			active_tool.deactivate();
			active_tool = null;
			if _mode == "building":
				Global.game.set_mode("platforming")
			get_viewport().set_input_as_handled();
		else:
			if !is_paused:
				is_paused = true;
				Engine.time_scale = 0.0;
			else:
				Engine.time_scale = 1.0;
				is_paused = false;
			
			pause_menu.visible = is_paused;
			
			
		
	elif(Input.is_action_just_pressed("quick_build")):
		if _mode == "building":
			Global.game.set_mode("platforming")
			if active_tool:
				active_tool.deactivate()
		elif _mode == "platforming":
			activate_tool(last_building_tool, last_tool_data);
			
	
	elif(Input.is_action_just_pressed("full_screen_toggle")):
		var currentMode = DisplayServer.window_get_mode();
		var targetMode = DisplayServer.WINDOW_MODE_FULLSCREEN if currentMode == DisplayServer.WINDOW_MODE_WINDOWED else DisplayServer.WINDOW_MODE_WINDOWED; 
		DisplayServer.window_set_mode(targetMode);
	elif(Input.is_action_just_pressed("debug_add_crumbs")):
		player.crumb_wallet.add(1000);
	elif(Input.is_action_just_pressed("debug_infinite_health")):
		player.health.invulnerable = !player.health.invulnerable ;
	elif(Input.is_action_just_pressed("debug_goto_next")):
		var warper := _current_level.get_warper();
		if warper && warper.destination:
			SceneFlow.load_level(warper.destination);
	
	
# ugly workaround for resets not fully working
func _on_reset_timer_timeout() -> void:
	if player.health.is_dead:
		SceneFlow.load_level(start_level);
		Events.on_new_game.emit();
	else:
		_is_resetting_level = true;
		SceneFlow.call_deferred("reload_current")
