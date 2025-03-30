class_name WorldScroller2D extends Node2D

@export var start_speed : float = 10.0
@export var max_speed : float = 25.0
@export var speed_increment : float = 5.0
@export var main_snake_speed_increment : float = 2.5
@export var speed_reduction_on_damage_taken : float = 5.0
@export_file var starting_tile : Array[String]

@onready var player : Player = $player/avatar
@onready var background : ParallaxBackground = $background
@onready var camera : CameraTracker2D = $player/camera
@onready var temp_floor = $temp_floor
@onready var game_over : GameOverMenu = $game_over
@onready var main_snake : MainSnake = $main_snake
@onready var background_music : BackgroundAudioStream= $background_music
@onready var score : Label = $hud/score

var speed : float
var snake_speed : float
var spawn_tile_pos : Vector2
var target_level_tile : LevelTile2D
var run_state : bool = true
var move_snake : bool = false
var transition_flag : bool = true
var current_score : int = 0
var current_phase : int = 0
var node_to_focus : Node2D


var main_snake_spawn_pos : Vector2

class InstantiatedTile:
	var tile_node : Node2D
	var tile_data : LevelTile2D

var existing_tiles : Array[InstantiatedTile]

static var ins_ref : WorldScroller2D

static func increment_score(value : float) -> void:
	ins_ref.current_score += value

func _ready() -> void:
	player.on_player_death.connect(_on_game_over)
	player.on_player_damage_taken.connect(_on_damage_taken)
	game_over.init(self)
	main_snake_spawn_pos = main_snake.position
	new_game()

func new_game() -> void:
	background_music.set_phase(1, true)
	player.respawn(Vector2.ZERO)
	main_snake.position = main_snake_spawn_pos
	main_snake.reset()
	camera.node_to_track = player
	camera.position_smoothing_enabled = false
	spawn_tile_pos = Vector2.ZERO

	speed = start_speed
	snake_speed = start_speed

	target_level_tile = _select_random_starting_tile()
	_spawn_tile()
	run_state = true
	game_over.disable()
	current_score = 0

	var tween = get_tree().create_tween()
	tween.tween_interval(1).finished.connect(func():
		move_snake = true
		)
	node_to_focus = player
	transition_flag = true

func _on_game_over(killer : Node2D) -> void:
	camera.node_to_track = killer
	node_to_focus = killer
	camera.position_smoothing_enabled = true
	run_state = false
	game_over.update_score(current_score)
	game_over.enable()
	background_music.set_phase(0)

func _on_damage_taken() -> void:
	speed -= speed_reduction_on_damage_taken

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
	score.text = "Score: %s" % str(current_score)

	_update_music()
	_update_snake()

	# calculate the distance between the newest tile and the player
	var newest_tile := existing_tiles[len(existing_tiles) - 1]
	var dist = (newest_tile.tile_node.position - node_to_focus.global_position).length()
	# print("Dist to recent tile. %f" % dist)
	# if the tile is closer to the player than some limit, spawn a new tile
	if dist < newest_tile.tile_data.tile_size.x / 1.25:
		_spawn_tile()

	if !run_state:
		return
	speed += speed_increment * delta
	snake_speed += main_snake_speed_increment * delta
	#print("Current Speed (player: %f, snake:%f)" % [speed, snake_speed])

	speed = clamp(speed, 0, max_speed)
	snake_speed = clamp(snake_speed, 0, max_speed)

	current_score += 1
	# move player and camera
	player.velocity.x = speed
	main_snake.update_speed(snake_speed)


func _update_music() -> void:
	if !transition_flag:
		return

	var new_phase = 1
	if current_score > 5000:
		new_phase = randi_range(1,2)
	elif current_score > 10000:
		new_phase = randi_range(1,3)

	if new_phase != current_phase:
		transition_flag = true
		get_tree().create_timer(6.0).timeout.connect(func():
			current_phase = new_phase
			background_music.set_phase(current_phase)
			)




func _update_snake() -> void:
	if move_snake:
		var dir = (player.position - main_snake.get_head_pos()).normalized()
		var cardinal_dir = _calculate_cardinal_dir(dir)
		if player.is_dead():
			cardinal_dir = Vector2.RIGHT
		main_snake.update_direction(cardinal_dir)

func _calculate_cardinal_dir(dir : Vector2) -> Vector2:
	const detection_radian := 0.3

	var dot = dir.dot(Vector2.UP)
	if dot > detection_radian:
		return Vector2.UP
	elif dot < -detection_radian:
		return Vector2.DOWN

	dot = dir.dot(Vector2.LEFT)
	if dot > detection_radian:
		return Vector2.LEFT
	return Vector2.RIGHT
