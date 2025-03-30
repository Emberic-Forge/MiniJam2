class_name BackgroundAudioStream extends Node2D

const BPM := 145.0

@export var low_pass_filter : AudioEffectLowPassFilter
@onready var bus_indx = AudioServer.get_bus_index("Music")

var background_players : Array[AudioStreamPlayer]

func _ready() -> void:
	AudioServer.add_bus_effect(bus_indx, low_pass_filter)
	set_low_pass(false)
	for player in get_children():
		background_players.append(player)

func get_background_players() -> Array[AudioStreamPlayer]:
	return background_players

func set_low_pass(value : bool) -> void:
	AudioServer.set_bus_effect_enabled(bus_indx, 0, value)

func set_phase(new_phase : int, reset_flag : bool = false) -> void:
	assert(new_phase < len(background_players), "Attempted to play an invalid phase!")
	var tween = get_tree().create_tween().set_parallel()
	for player in background_players:
			if reset_flag:
				player.volume_linear = 0
				player.play(0)
			else:
				tween.tween_property(player, "volume_linear", 0, 60.0/BPM)
	tween.tween_property(background_players[new_phase], "volume_linear", 1, 60/BPM)
	print("Switched music phase!")
