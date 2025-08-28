class_name Player
extends CharacterBody2D

const SPEED = 300.0
var jump_velocity := -600.0

var can_jump: bool;
var is_jumping: bool;
var jump_counter:= 0;
var previous_velocity : Vector2;
var flip_x: bool;

@onready var coyote_timer: Timer = $CoyoteTimer
@export var jump_count_max := 10
@export var gravity_modifier := 1.0
@onready var health: Health = $Health
@onready var crumb_wallet: CrumbWallet = $CrumbWallet
@export var force_damping : float = 0.9;
@onready var hurt_sound: VariedAudioStreamPlayer2D = $HurtSound

@export var state:State = State.Platforming;

@export var force: Vector2 = Vector2.ZERO;

enum State 
{
	Platforming,
	Building,
	Locked
}

func _ready() -> void:
	crumb_wallet.set_count(0);
	health.on_hurt.connect(_on_hurt);
	Events.on_toggle_build_mode.connect(on_build_mode_toggled);
	

func on_build_mode_toggled(enabled: bool) -> void:
	if enabled && state == State.Platforming:
		set_state(State.Building);
	
	elif !enabled && state == State.Building:
		set_state(State.Platforming);
	

func set_state(new_state: State) -> void:
	if state == new_state:
		return;
	
	
	state = new_state;
	
func reset_position() -> void:
	var start := get_tree().get_first_node_in_group("map_start")
	if !start:
		printerr("no map start found!");
		
	global_position = start.global_position;
	
func _on_hurt(amount:float, fatal: bool, source: StringName) -> void:
	if source == "hazard":
		reset_position();
	
	hurt_sound.play_any()
	Events.on_player_hurt.emit(amount, fatal, source)
	
func add_crumbs(count: int) -> void:
	crumb_wallet.add(count);
	
func _stop_jump() -> void:
	is_jumping = false
	velocity.y = max(velocity.y, 0)
	jump_counter = 0
	
func _jump() -> void:
	velocity.y = jump_velocity 
	is_jumping = true
	can_jump = false
	jump_counter += 1;
	##jump_velocity_override = -1.0;
	
func _physics_process(delta: float) -> void:
	
	if Global.game._mode != "platforming":
		return;
	
	if(previous_velocity.y > 0):
		for index in range(get_slide_collision_count()):
			var collision = get_slide_collision(index)
			if collision.get_collider() == null:
				continue
			
			var collider = collision.get_collider()
			if collider.is_in_group("platform"):
				if Vector2.UP.dot(collision.get_normal()) > 0.1:
					collider.impact(self);
	
	
	previous_velocity = velocity;
	
	if not is_on_floor():
		velocity += get_gravity() * delta

	var is_input_jump := Input.is_action_pressed("jump");
	
	if is_input_jump:
		if can_jump || (is_jumping && jump_counter < jump_count_max):
			_jump();
	elif is_jumping:
		_stop_jump()

	elif !can_jump and is_on_floor():
		can_jump = true
		
	if !is_on_floor() and can_jump and coyote_timer.is_stopped():
		coyote_timer.start()

	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	if(velocity.x != 0):
		if flip_x && velocity.x > 0:
			flip_x = false;
			scale.x *= -1;
		elif !flip_x && velocity.x < 0:
			flip_x = true;
			scale.x *= -1;
	
	velocity += force;
	force *= force_damping;
	
	update_animation();
	move_and_slide()

func _on_coyote_timer_timeout() -> void:
	can_jump = false;

func update_animation():
	var on_floor := is_on_floor();
	
	if on_floor && previous_velocity.x == 0 && velocity.x != 0:
		$entity_000/Skeleton/AnimationPlayer.play("scml/run");
	elif previous_velocity.x != 0 && velocity.x == 0:
		$entity_000/Skeleton/AnimationPlayer.play("scml/idle");
		
func _on_zone_checker_area_entered(area: Area2D) -> void:
	if(area.is_in_group("build_allowed_area")):
		pass
		
