extends Node

var _currentLevel: Node;
var _current_level_path: String;

func reload_current() -> void:
	load_level(_current_level_path);
	
func load_level(scene:String) -> void:
	_unload_active_level();
	var scene_res : PackedScene = load(scene);
	
	if not scene_res:
		print("trying to load scene %s but it does not seem to exist." % scene);
		return;
		
	_change_scene(load(scene) as PackedScene);
	_current_level_path = scene;
	

func _unload_active_level() -> void:
	if is_instance_valid(_currentLevel):
		_currentLevel.queue_free();
	
func _change_scene(scene_res:PackedScene):
	_currentLevel = scene_res.instantiate() as Node;
	Global.game.call_deferred("add_child", _currentLevel);
	
	_currentLevel.ready.connect(_on_level_ready);
	
func _on_level_ready():
	Global.game.call_deferred("set_current_level");
	
