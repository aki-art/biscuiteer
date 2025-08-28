@tool
extends Node
class_name FitCollider

@export_tool_button("Create") var hello_action = hello

func hello():
	var parent = get_parent() as Polygon2D
	
	if !parent:
		print("FitCollider wants a polygon 2d parent");
		return;
	
	match_all(parent, parent.polygon);

func match_all(node: Node, points: PackedVector2Array) -> void:
	for child in node.get_children(true):
		var collision := child as CollisionPolygon2D;
		
		if collision:
			if collision.polygon == null || collision.polygon.size() == 0:
				collision.polygon = points.duplicate()
			
		else:
			match_all(child, points);
