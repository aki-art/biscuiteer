class_name Player
extends CharacterBody2D

const SPEED = 300.0

var jump_velocity := -600.0
var can_jump: bool;
var is_jumping: bool;
var jump_counter:= 0;
var previous_velocity : Vector2;
var flip_x: bool;
var trying_to_move: bool;
var is_honeyed: bool;

@export var state:StringName = "idle"
@export var jump_count_max := 10
@export var gravity_modifier := 1.0
@export var force_damping : float = 0.9;
@export var force: Vector2 = Vector2.ZERO;
@export var max_falling_speed := 300.0;
@export var honey_speed_modifier := 0.5;
@export var honey_jump_modifier := 0.5;

@onready var health: Health = $Health
@onready var crumb_wallet: CrumbWallet = $CrumbWallet
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var walk_dust: CPUParticles2D = $WalkDust
@onready var land_audio: AudioStreamPlayer2D = $LandAudio
@onready var coyote_timer: Timer = $CoyoteTimer
@onready var damage_particles: CPUParticles2D = $DamageParticles
@onready var debug_label: Label = $DebugLabel
@onready var slap_cooldown_timer: Timer = $SlapCooldownTimer
@onready var entity_000: Node2D = $entity_000
@onready var honey_timer: Timer = $HoneyTimer


static var control_state : Array[StringName] = ["idle", "running", "jumping", "___slap", "falling"];

func can_control() -> bool:
	return control_state.has(state)
	

func set_flip(facing_left: bool) -> void:
	flip_x = facing_left;
	var mult := -1.0 if facing_left else 1.0;
	entity_000.scale.x = mult;
	
func set_state(new_state: StringName) -> void:
	if new_state == state:
		return;
	
	match new_state:
		"slap":
			slap_cooldown_timer.start()
		#"dead":
			#$DeathParticles.restart()
	
	walk_dust.emitting = new_state == "running"
	animation_tree.set("parameters/state/transition_request", new_state);
			
	state = new_state;
		
func _ready() -> void:
	health.on_hurt.connect(_on_hurt);
	Events.on_game_mode_changed.connect(_on_game_mode_changed);
	Events.on_level_reset.connect(_on_level_reset);
	
	health.set_hp(4);

func _on_level_reset() -> void:
		if state == "dead":
			health.set_hp(4)
			
		set_state("idle");
		reset_position();
		
func _on_game_mode_changed(mode: StringName) -> void:
	honey_timer.paused = mode == "building";
	
func add_honey_effect() -> void:
	honey_timer.start();
	is_honeyed = true;
	Events.on_honeyed.emit();
	
func _process(d):
	
	debug_label.text = str(state);
	#if Input.is_action_pressed("slap") && slap_cooldown_timer.is_stopped():
		#set_state("slap")
	
func reset_position() -> void:
	var start := get_tree().get_first_node_in_group("map_start")
	if !start:
		printerr("no map start found!");
		
	global_position = start.global_position;
	
func _on_hurt(amount:float, fatal: bool, source: StringName, position: Vector2) -> void:
	if source == "hazard" && !fatal:
		reset_position();
	 
	Events.on_player_hurt.emit(amount, fatal, source)
	set_state("dead" if fatal else "hurt")
	
func add_crumbs(count: int) -> void:
	crumb_wallet.add(count);
	
func _stop_jump() -> void:
	is_jumping = false
	velocity.y = max(velocity.y, 0)
	jump_counter = 0
	set_state("idle")
	
func _jump() -> void:
	
	velocity.y = jump_velocity 
	if is_honeyed:
		velocity.y *= honey_jump_modifier;
		
	is_jumping = true
	can_jump = false
	jump_counter += 1;
	set_state("jumping")
	##jump_velocity_override = -1.0;


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_hurt"):
		health.damage(1, "debug", get_global_mouse_position());
		
func _physics_process(delta: float) -> void:
	
	var restrained := Global.game._mode != "platforming" || !can_control();
	if state == "slap":
		print (restrained);
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

	if !restrained:
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
	if !restrained && direction:
		velocity.x = direction * SPEED
		if is_honeyed:
			velocity.x *= honey_speed_modifier;
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	velocity.y = min(max_falling_speed, velocity.y);
	
	trying_to_move = velocity.x != 0;
	if(trying_to_move):
		set_flip(velocity.x < 0);
	
	if !is_jumping && !is_on_floor():
		if control_state.has(state):
			set_state("falling");
	elif state == "falling":
		land_audio.play();
		set_state("idle");
		
	update_animation();
	move_and_slide()
	
func _on_coyote_timer_timeout() -> void:
	can_jump = false;

func update_animation():
	if !can_control():
		return;
	var on_floor := is_on_floor();
	
	var previous_h : bool = abs(previous_velocity.x) < 0.01;
	var current_h : bool = abs(velocity.x) < 0.01;
	var previous_v : bool = abs(previous_velocity.y) < 0.01;
	var current_v : bool = abs(velocity.y) < 0.01;
	
	if trying_to_move && state == "idle":
		set_state("running");
	elif !trying_to_move && state == "running":
		set_state("idle");
		
func _on_zone_checker_area_entered(area: Area2D) -> void:
	if(area.is_in_group("build_allowed_area")):
		pass
		


func _on_animation_tree_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		"scml/hit":
			if state != "dead":
				set_state("idle");
		"scml/slap":
			if state != "dead":
				set_state("idle");


func _on_health_on_hurt(amount: float, fatal: bool, source: StringName, pos: Vector2) -> void:
	var aim = Vector2.UP;
	if pos:
		aim = (global_position - pos).normalized();
		
	damage_particles.direction = aim;
	damage_particles.restart();
	
	if !fatal:
		force += (global_position - pos).normalized() * 2;


func _on_honey_timer_timeout() -> void:
	is_honeyed = false;
	Events.on_honey_dried.emit();
