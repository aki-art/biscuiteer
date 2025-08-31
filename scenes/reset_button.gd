class_name ResetButton
extends Control

@onready var texture_progress_bar: TextureProgressBar = $TextureProgressBar
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

var elapsed := 0.0;
const DURATION := 2.0;
var is_pressed := false;
var is_key_pressed := false;
var was_pressed := false;

func _process(delta: float) -> void:
	
	var is_inputting_reset := Input.is_action_pressed("reset");
	
	if is_pressed || is_inputting_reset:
		
		if !was_pressed:
			audio_stream_player.play(0);
			was_pressed = true;
			
		elapsed += delta;
		if elapsed > DURATION:
			Global.game.reset_level();
			stop();
			
		texture_progress_bar.value = (elapsed / DURATION) * 100;
	else:
		if was_pressed:
			stop();

func stop() -> void:
			texture_progress_bar.value = 0;
			is_pressed = false;
			elapsed = 0;
			audio_stream_player.stop();
			was_pressed = false;
	
			
func _on_button_down() -> void:
	is_pressed = true;
		

func _on_button_up() -> void:
	is_pressed = false;
