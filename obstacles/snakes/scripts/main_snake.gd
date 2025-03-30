class_name MainSnake extends Node2D

@export_file var snake_segment : String
@export var segment_size : Vector2 = Vector2(55,55)
@export var segment_amount : int = 5

var packed_snake_segment : PackedScene
@onready var segment_updater : Timer = $segment_updater

var target_direction : Vector2

var data = []
var old_data = []
var segments : Array[Node2D]

func update_direction(new_dir : Vector2) -> void:
	target_direction = new_dir

func get_head_pos() -> Vector2:
	return segments[0].position

func reset() -> void:
	old_data.clear()
	data.clear()

	if !segment_updater.is_stopped():
		segment_updater.stop()
	segment_updater.start()

	for i in range(len(segments)):
		_set_segment(i, Vector2(-i,0))


func update_speed(new_speed : float) -> void:
	segment_updater.wait_time =  segment_size.x / new_speed

func _ready() -> void:
	packed_snake_segment = load(snake_segment)
	for i in range(segment_amount):
		_add_segment(Vector2(-i,0))

	segment_updater.timeout.connect(_update_segments)
	reset()

func _set_segment(index : int, pos : Vector2) -> void:
	data.append(pos)
	segments[index].position = (position + (pos * segment_size))

func _add_segment(pos : Vector2) -> void:
	data.append(pos)
	var seg = packed_snake_segment.instantiate()
	seg.position = (position + (pos * segment_size))
	get_parent().call_deferred("add_child", seg)
	segments.append(seg)

func _update_segments() -> void:
	old_data = [] + data
	data[0] += target_direction

	for i in range(len(data)):
		if i > 0:
			data[i] = old_data[i - 1]
		segments[i].position = position + (data[i] * segment_size)
