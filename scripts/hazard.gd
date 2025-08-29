class_name Hazard
extends Node2D

signal on_touched(node: Node2D)

func _ready() -> void:
	on_touched.connect(_on_touched);

func get_health_node(node:Node) -> Health:
	for child in node.get_children(false):
		if child is Health:
			return child;
		
	return null;
	
func _on_touched(node:Node2D) -> void:
	var health := get_health_node(node);
	if(health):
		health.damage(1, "hazard", global_position);
