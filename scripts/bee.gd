extends RigidBody2D

@onready var animation_player: AnimationPlayer = $BeeAnimation/Skeleton/AnimationPlayer

var state: StringName = "idle";
var player_in_range: bool = false;
@onready var ray_cast_2d: RayCast2D = $RayCast2D
var player: Node2D;
@onready var bee_animation: Node2D = $BeeAnimation
var flip_x: bool;

func change_state(new_state: StringName):
	if state == new_state:
		return;
	
	match new_state:
		"idle":
			animation_player.play("scml/idle")
		"hit":
			animation_player.play("scml/hit")
		"chasing_player":
			animation_player.play("scml/idle")
			
		
	state = new_state;

func _physics_process(delta: float) -> void:
	if player_in_range:
		# todo_check vis
		ray_cast_2d.target_position = player.global_position - global_position;
		apply_force((player.global_position - global_position).normalized() * 505);
	
	angular_velocity = 0;
	
func _ready() -> void:
	animation_player.play("scml/idle")
	player = get_tree().get_first_node_in_group("player")
	Events.on_game_mode_changed.connect(_on_game_mode_changed);
	

func _on_game_mode_changed(mode:StringName):
	freeze = mode == "building";
	

func _process(delta: float) -> void:
	if flip_x && linear_velocity.x > 0:
		flip_x = false;
		bee_animation.scale.x *= -1;
	elif !flip_x && linear_velocity.x < 0:
		flip_x = true;
		bee_animation.scale.x *= -1;
	
	
func _integrate_forces(state):
	state.linear_velocity = state.linear_velocity.limit_length(300)
	
	if !player_in_range:
		state.apply_central_force(-state.linear_velocity * 0.95)

func _on_player_detection_range_body_entered(body: Node2D) -> void:
	player_in_range = true;


func _on_player_detection_range_body_exited(body: Node2D) -> void:
	player_in_range = false;


func _on_damage_area_body_entered(body: Node2D) -> void:
	if body is Player:
		body.health.damage(1, "enemy", global_position);
