extends RichTextLabel


func _ready() -> void:
	Events.on_crumbs_changed.connect(_on_crumbs_changed);

func _on_crumbs_changed(new_count: int) -> void:
	text = "[b]%d[/b]" % new_count;
