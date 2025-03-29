class_name LevelTile2D extends Resource

@export_file var acceptable_neighbours : Array[String]
@export var tile_scene : PackedScene
@export var tile_size : Vector2 = Vector2(300,300)


func initiate_tile(position : Vector2, owner : Node2D) -> Node2D:
	var scene = tile_scene.instantiate()
	owner.add_child(scene)

	scene.position = position
	return scene

func get_random_neighbour() -> LevelTile2D:
	var indx = randi_range(0, max(len(acceptable_neighbours) - 1, 0))
	assert(acceptable_neighbours[indx], "Attempted to return an empty tile")
	return load(acceptable_neighbours[indx]) as LevelTile2D
