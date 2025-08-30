class_name Platform
extends StaticBody2D

@onready var impact_dust_particles: GPUParticles2D = $ImpactDustParticles


@onready var visualizer: Node2D = $Visualizer
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var audio_cooldown_timer: Timer = $AudioCooldownTimer
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var biscuit_click_audio: AudioStreamPlayer2D = $BiscuitClickAudio
@onready var varied_audio_stream_player_2d: VariedAudioStreamPlayer2D = $VariedAudioStreamPlayer2D
@onready var line_2d: Line2D = $Visualizer/Line2D

@export var is_active: bool = false;
@export var snap_length:float = -1.0;
@export var min_length = 0.0;
@export var cost_per_unit := 1;
@export var honeyed: bool;

var previous_segment_count := -1;
var cost: int;

func _ready() -> void:
	if is_active:
		activate(false)
		set_ends(line_2d.points[0], line_2d.points[1], true, false, false);
		modulate = Color.WHITE;

func activate(play_animation: bool) -> void:
	is_active = true;
	collision_shape_2d.set.call_deferred("disabled", false);
	
	modulate = Color.WHITE;
	
	if play_animation:
		_play_impact_animation()

func impact(node: Node2D) -> void:
	_play_impact_animation();
	
func deactivate() -> void:
	is_active = false;
	collision_shape_2d.set.call_deferred("disabled", true);

var flip_x := false;

func _check_cost(units: float) -> void:
	var can_afford := Global.game.player.crumb_wallet.can_afford(units);
	modulate = Color.WHITE if can_afford else Color.FIREBRICK;
	modulate.a = 0.7;
	
func set_ends(start:Vector2, end:Vector2, update_colliders:bool, play_audio:bool, preview:bool) -> void:
	#position = lerp(start, end, 0.5)
	# just for testing
	
	if start.x > end.x:
		# flip
		var p := start;
		start = end;
		end = p;
		if(!flip_x):
			flip_x = true;
			scale.x *= -1.0;
	else:
		if flip_x:
			scale.x *= -1.0;
			flip_x = false;
	
	
	var len := start.distance_to(end);
	len = max(len, min_length);
	var segment_count : int = len / snap_length;
	
	cost = segment_count * cost_per_unit;
	if preview:
		_check_cost(cost);
	
	if play_audio && snap_length > 0:
		if(segment_count != previous_segment_count && audio_cooldown_timer.is_stopped()):
			var pitch := remap(len, min_length, 300.0, 0.7, 1.5);
			pitch = clamp(pitch, 0.8, 1.1);
			biscuit_click_audio.pitch_scale = pitch;
			
			biscuit_click_audio.play();
			audio_cooldown_timer.start();
			previous_segment_count = segment_count;
			
	if snap_length > 0.0:
		len = snappedf(len, snap_length);
	
	
	var angle := start.angle_to_point(end);
	
		
	var end_pos := Vector2(len, 0);
	$Visualizer/Line2D.set_point_position(1, end_pos);
	
	if Input.is_key_pressed(KEY_SHIFT):
		angle = snappedf(angle, TAU / 8.0);
	
	$Visualizer/Line2D/RightCapSprite.position = end_pos;
	
	rotation = angle;
	
	if update_colliders:
		var vertical := start.x == end.x;
		var center := Vector2(len / 2.0, 0);
		$CollisionShape2D.position.x = center.x;
		$CollisionShape2D.shape.size.x = len;
					
		var mat := $ImpactDustParticles.process_material as ParticleProcessMaterial;
		mat.emission_box_extents.x = len / 2.0;
		mat.emission_shape_offset.x = len / 2.0;
		$ImpactDustParticles.amount = (len / snap_length) * 2.0;
		

func _play_impact_animation()-> void:
	impact_dust_particles.restart()
	animation_player.play("jumped_on")
	varied_audio_stream_player_2d.pitch_scale = randf_range(0.9, 1.1)
	varied_audio_stream_player_2d.play_any();

func destroy() -> void:
	Global.game.remove_targets.erase(self);
	queue_free();
	
	

func _on_mouse_entered() -> void:
	if Global.game.active_tool is RemoverTool && !Global.game.remove_targets.has(self):
		modulate *= Color(1.15, 1.15, 1.15, 1.0);
		Global.game.remove_targets.append(self);


func _on_mouse_exited() -> void:
	if Global.game.active_tool is RemoverTool && Global.game.remove_targets.has(self):
		modulate /= Color(1.15, 1.15, 1.15, 1.0);
		Global.game.remove_targets.erase(self);
