extends HFlowContainer

const HEART_DISPLAY = preload("res://scenes/heart_display.tscn")

var current_num := 0;

func _ready() -> void:
	Events.on_player_hp_changed.connect(_on_player_hp_changed);

func _on_player_hp_changed(new_hp: int) -> void:
	update_health(new_hp);
	
func update_health(amount: int) -> void:
	var current_display := get_child_count();
	if amount == current_display: return;
	
	for child in get_children():
		child.queue_free();
	
	for i in amount:
		var piece := HEART_DISPLAY.instantiate();
		add_child(piece);
