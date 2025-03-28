class_name WorldScroller2D extends Node2D

@export var start_speed : float = 10.0
@export var max_speed : float = 25.0

@onready var player : Player = $player/avatar
@onready var background : ParallaxBackground = $background
@onready var camera : Camera2D = $player/camera
@onready var temp_floor = $temp_floor
@onready var screen_size := camera.get_viewport_rect().size / camera.zoom

var speed : float
var cam_starting_pos : Vector2


func _ready() -> void:
	cam_starting_pos = camera.position
	_new_game()

func _new_game() -> void:
	player.position = Vector2.ZERO
	player.velocity = Vector2.ZERO
	camera.position = cam_starting_pos

	speed = start_speed

func _process(delta : float) -> void:
	var offset = speed * delta

	# move player and camera
	player.position.x += offset
	camera.position.x += offset

	#update ground position
	if camera.position.x - temp_floor.position.x > screen_size.x * 1.5:
		temp_floor.position.x += screen_size.x
