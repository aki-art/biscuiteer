class_name Level
extends Node


func start_level(player: Player) -> void:
	var start_markers := get_tree().get_nodes_in_group("map_start");
	
	if start_markers.size() == 0:
		printerr("No start marker on map!");
		return;
	
	if start_markers.size() > 1:
		printerr("multiple start markers!");
	
	player.position = start_markers[-1].position;
	player.set_flip(start_markers[-1].facing_left);
	
	
	var camera := get_viewport().get_camera_2d();
	var nodes := get_tree().get_nodes_in_group("camera_extents");
	if !nodes:
		return;
		
	var camera_extents = nodes[-1];
	
	var custom_limits := false;
	if camera && camera_extents:
		var top_left: Node2D = camera_extents.get_node("top_left");
		var bottom_right: Node2D = camera_extents.get_node("bottom_right");
		
		if top_left && bottom_right:
			camera.limit_bottom = bottom_right.global_position.y;
			camera.limit_top = top_left.global_position.y;
			camera.limit_left = top_left.global_position.x;
			camera.limit_right = bottom_right.global_position.x;
			custom_limits = true;
	
	if !custom_limits:
		camera.limit_bottom = 10000000;
		camera.limit_left = -10000000;
		camera.limit_right = 10000000;
		camera.limit_top = -10000000;
		
	
	
