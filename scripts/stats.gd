extends VBoxContainer


var crumbs := 0;
var platforms := 0;

var previous_crumbs := 0;
var previous_platforms := 0;

@onready var platform_bits_built: RichTextLabel = $PlatformBitsBuilt
@onready var total_crumbs: RichTextLabel = $TotalCrumbs

func _ready() -> void:
	Events.on_crumbs_earnt.connect(_on_crumbs_earnt);
	Events.on_platform_built.connect(_on_platform_built);
	Events.on_level_reset.connect(_on_level_reset);
	Events.on_level_loaded.connect(_on_level_loaded);
	update_labels()

func update_labels() -> void:
	total_crumbs.text = "Total Crumbs: %s" % crumbs;
	platform_bits_built.text = "Platform Bits Built: %s" % platforms;
	
func _on_level_reset() -> void:
	crumbs = previous_crumbs;
	platforms = previous_platforms;
	update_labels()

func _on_level_loaded(_level: Level, is_reset: bool) -> void:
	if !is_reset:
		previous_crumbs = crumbs;
		previous_platforms = platforms;
		update_labels()
	
func _on_crumbs_earnt(amount: int):
	crumbs += amount;
	update_labels()
	
	
func _on_platform_built(amount: int):
	platforms += amount;
	update_labels()
