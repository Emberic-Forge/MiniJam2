class_name WorldScroller2D extends Node2D

@export var start_speed : float = 10.0
@export var max_speed : float = 25.0
@export_file var starting_tile : Array[String]

@onready var player : Player = $player/avatar
@onready var background : ParallaxBackground = $background
@onready var camera : CameraTracker2D = $player/camera
@onready var temp_floor = $temp_floor
@onready var game_over : GameOverMenu = $game_over

var speed : float
var spawn_tile_pos : Vector2
var target_level_tile : LevelTile2D
var run_state : bool = true
var current_score : int = 0

class InstantiatedTile:
	var tile_node : Node2D
	var tile_data : LevelTile2D

var existing_tiles : Array[InstantiatedTile]

func _ready() -> void:
	player.on_player_death.connect(_on_game_over)
	game_over.init(self)
	new_game()

func new_game() -> void:
	player.respawn(Vector2.ZERO)
	camera.node_to_track = player
	spawn_tile_pos = Vector2.ZERO

	speed = start_speed

	target_level_tile = _select_random_starting_tile()
	_spawn_tile()
	run_state = true
	game_over.disable()
	current_score = 0

func _on_game_over(killer : Node2D) -> void:
	camera.node_to_track = killer
	run_state = false
	game_over.update_score(current_score)
	game_over.enable()

func _select_random_starting_tile() -> LevelTile2D:
	var index = randi_range(0, max(len(starting_tile) - 1,0))
	assert(starting_tile[index], "Attempting to return an empty tile")
	return load(starting_tile[index])

func _spawn_tile() -> void:
	# if more than 3 tiles exist, remove the oldest one
	if len(existing_tiles) > 3:
		var tile : InstantiatedTile = existing_tiles.pop_front()
		assert(tile, "Attempted to free an empty tile")
		tile.tile_node.queue_free()

	# instantiate the next one and store it
	var new_ins_tile = InstantiatedTile.new()
	new_ins_tile.tile_node = target_level_tile.initiate_tile(spawn_tile_pos, self)
	new_ins_tile.tile_data = target_level_tile

	existing_tiles.push_back(new_ins_tile)

	# offset the spawn_tile position by the tile size
	spawn_tile_pos.x += target_level_tile.tile_size.x;
	# get a random neighbour and assign it as the next tile
	target_level_tile = target_level_tile.get_random_neighbour()


func _process(delta : float) -> void:
	if !run_state:
		return
	current_score += 1
	var offset = speed * delta
	# move player and camera
	player.position.x += offset

	# calculate the distance between the newest tile and the player
	var newest_tile := existing_tiles[len(existing_tiles) - 1]
	var dist = (newest_tile.tile_node.position - player.position).length()
	# if the tile is closer to the player than some limit, spawn a new tile
	if dist < newest_tile.tile_data.tile_size.x / 1.25:
		_spawn_tile()
