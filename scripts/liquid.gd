extends Node2D

@export var milk_scroll_speed := 20.0;
@onready var milk_top: Polygon2D = $MilkTop
var milk_2 : Polygon2D;
@export var is_honey: bool;
var player : Player;

func _ready() -> void:
	var polygon : Polygon2D;
	for child in get_children(false):
		if child is Polygon2D && child != milk_top:
			polygon = child;
	
	$Area2D/CollisionPolygon2D.polygon = polygon.polygon;
	milk_2 = milk_top.duplicate();
	add_child(milk_2);
	milk_2.z_index = -1;
	
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("liquid_absorbable"):
		body.queue_free();
		return;
	
	if is_honey:
		var player = body as Player;
		if player:
			self.player = player;

func _process(delta: float) -> void:
	milk_top.texture_offset.x += delta * milk_scroll_speed;
	milk_2.texture_offset.x -= delta * milk_scroll_speed * 0.7;
	if player:
		player.add_honey_effect()

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body == self.player:
		self.player = null;
