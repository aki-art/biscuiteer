class_name VariedAudioStreamPlayer2D
extends AudioStreamPlayer2D

@export var streams : Array[AudioStream];

func play_any() -> void:
	stream = streams.pick_random();
	play();

func play_index(index: int) -> void:
	if index < 0 || index >= streams.size():
		return;
	
	stream = streams[index];
	play();
