class_name WorldScroller2D extends Node2D

@export var start_speed : float = 10.0
@export var max_speed : float = 25.0
@export var tile_size : Vector2 = Vector2(300, 300)
@export_file var starting_tile : Array[String]

@onready var player : Player = $player/avatar
@onready var background : ParallaxBackground = $background
@onready var camera : Camera2D = $player/avatar/camera
@onready var temp_floor = $temp_floor

var speed : float
var spawn_tile_pos : Vector2
var target_level_tile : LevelTile2D
var existing_tiles : Array[Node2D]

func _ready() -> void:
	new_game()

func new_game() -> void:
	player.position = Vector2.ZERO
	player.velocity = Vector2.ZERO
	spawn_tile_pos = Vector2.ZERO

	speed = start_speed

	target_level_tile = _select_random_starting_tile()
	_spawn_tile()


func _select_random_starting_tile() -> LevelTile2D:
	var index = randi_range(0, max(len(starting_tile) - 1,0))
	assert(starting_tile[index], "Attempting to return an empty tile")
	return load(starting_tile[index])

func _spawn_tile() -> void:
	# if more than 3 tiles exist, remove the oldest one
	if len(existing_tiles) > 3:
		var tile : Node2D = existing_tiles.pop_front()
		assert(tile, "Attempted to free an empty tile")
		tile.queue_free()

	# instantiate the next one and store it
	existing_tiles.push_back(target_level_tile.initiate_tile(spawn_tile_pos, self))
	# offset the spawn_tile position by the tile size
	spawn_tile_pos.x += tile_size.x;
	# get a random neighbour and assign it as the next tile
	target_level_tile = target_level_tile.get_random_neighbour()


func _process(delta : float) -> void:
	var offset = speed * delta
	# move player and camera
	player.position.x += offset

	# calculate the distance between the newest tile and the player
	var dist = (existing_tiles[len(existing_tiles) - 1].position - player.position).length()
	# if the tile is closer to the player than some limit, spawn a new tile
	if dist < tile_size.x / 1.25:
		_spawn_tile()
