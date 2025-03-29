class_name CameraTracker2D extends Camera2D

@export var node_to_track : Node2D

func _process(delta : float) -> void:
	global_position = node_to_track.global_position
