@tool
extends Polygon2D

@export_tool_button("Fix Up") var hello_action = hello

func hello():
	$FitCollider.fit();
	texture_offset = Vector2(
		wrapf(global_position.x, 0, texture.get_width()), 
		wrapf(global_position.y, 0, texture.get_height()));
	$Sideline.points = polygon.duplicate();
	print("fitter");
	
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
